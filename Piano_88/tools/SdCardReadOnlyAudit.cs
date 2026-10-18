using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text;

public static class SdCardReadOnlyAudit
{
    private static string Hash(byte[] data)
    {
        using (var sha = SHA256.Create()) return Hex(sha.ComputeHash(data));
    }

    private static string Hex(byte[] data)
    {
        return BitConverter.ToString(data).Replace("-", "");
    }

    private static byte[] ReadAt(FileStream source, long offset, int length)
    {
        source.Position = offset;
        byte[] data = new byte[length];
        int received = 0;
        while (received < length)
        {
            int count = source.Read(data, received, length - received);
            if (count == 0) throw new EndOfStreamException("Short read at " + (offset + received));
            received += count;
        }
        return data;
    }

    private static uint U32(byte[] data, int offset) { return BitConverter.ToUInt32(data, offset); }
    private static ushort U16(byte[] data, int offset) { return BitConverter.ToUInt16(data, offset); }

    private static int Crc16(byte[] data)
    {
        int crc = 0;
        foreach (byte value in data)
        {
            crc ^= value << 8;
            for (int bit = 0; bit < 8; bit++)
                crc = ((crc << 1) ^ ((crc & 0x8000) != 0 ? 0x1021 : 0)) & 0xffff;
        }
        return crc;
    }

    private static Dictionary<string, object> Describe(byte[] sector, long offset, long startLba)
    {
        return new Dictionary<string, object> {
            {"VolumeByteOffset", offset}, {"PhysicalByteOffset", startLba * 512 + offset},
            {"PhysicalLbaFloor", startLba + offset / 512}, {"ByteWithinSector", offset % 512},
            {"First16", BitConverter.ToString(sector, 0, 16)},
            {"Last16", BitConverter.ToString(sector, sector.Length - 16, 16)},
            {"Crc16", Crc16(sector).ToString("X4")}, {"Sha256", Hash(sector)}
        };
    }

    private static List<uint> Chain(uint first, byte[] fat, uint clusters)
    {
        var chain = new List<uint>();
        var visited = new HashSet<uint>();
        uint current = first;
        while (current < 0x0ffffff8)
        {
            if (current < 2 || current >= clusters + 2 || !visited.Add(current))
                throw new InvalidDataException("Invalid/looping FAT chain at cluster " + current);
            chain.Add(current);
            current = U32(fat, checked((int)current * 4)) & 0x0fffffff;
        }
        return chain;
    }

    private static byte[] ReadChain(FileStream source, List<uint> chain, long dataOffset, int clusterBytes)
    {
        using (var output = new MemoryStream())
        {
            foreach (uint cluster in chain)
            {
                var data = ReadAt(source, dataOffset + (cluster - 2L) * clusterBytes, clusterBytes);
                output.Write(data, 0, data.Length);
            }
            return output.ToArray();
        }
    }

    private static Dictionary<string, object> FileSystem(FileStream source, long size, long startLba,
                                                          string outputDir, List<string> issues)
    {
        byte[] boot = ReadAt(source, 0, 512);
        File.WriteAllBytes(Path.Combine(outputDir, "boot.bin"), boot);
        int sectorBytes = U16(boot, 11), perCluster = boot[13], reserved = U16(boot, 14);
        int fats = boot[16];
        uint total = U16(boot, 19) != 0 ? U16(boot, 19) : U32(boot, 32);
        uint fatSectors = U16(boot, 22) != 0 ? U16(boot, 22) : U32(boot, 36);
        uint root = U32(boot, 44);
        long dataSector = reserved + (long)fats * fatSectors;
        if (sectorBytes != 512 || perCluster == 0 || (perCluster & (perCluster - 1)) != 0
            || reserved == 0 || fats < 1 || fats > 2 || fatSectors == 0
            || dataSector >= total || (long)total * 512 > size)
            throw new InvalidDataException("Invalid FAT geometry");
        uint clusters = (uint)((total - dataSector) / perCluster);
        if (clusters < 65525 || U16(boot, 17) != 0 || U16(boot, 22) != 0
            || (long)(clusters + 2) * 4 > (long)fatSectors * 512)
            throw new InvalidDataException("Expected a valid FAT32 volume");
        if (boot[510] != 0x55 || boot[511] != 0xaa) issues.Add("Bad boot signature");
        if (boot[0] != 0xeb && boot[0] != 0xe9) issues.Add("Invalid boot jump");
        if (U32(boot, 28) != startLba) issues.Add("BPB hidden-sector count differs from partition offset");
        int backupSector = U16(boot, 50), infoSector = U16(boot, 48);
        bool? backupMatches = null;
        if (backupSector != 0 && backupSector < reserved)
        {
            var backup = ReadAt(source, backupSector * 512L, 512);
            backupMatches = Hash(boot) == Hash(backup);
            File.WriteAllBytes(Path.Combine(outputDir, "backup_boot.bin"), backup);
            if (backupMatches != true) issues.Add("Backup boot sector differs");
        }
        byte[] fat = ReadAt(source, reserved * 512L, checked((int)fatSectors * 512));
        long fatDifferences = 0;
        if (fats == 2)
        {
            byte[] second = ReadAt(source, (reserved + (long)fatSectors) * 512, fat.Length);
            for (int i = 0; i < fat.Length; i++) if (fat[i] != second[i]) fatDifferences++;
            if (fatDifferences != 0) issues.Add("FAT copies differ");
        }
        long free = 0, bad = 0, invalid = 0, allocated = 0;
        for (uint cluster = 2; cluster < clusters + 2; cluster++)
        {
            uint next = U32(fat, checked((int)cluster * 4)) & 0x0fffffff;
            if (next == 0) free++;
            else if (next == 0x0ffffff7) bad++;
            else
            {
                allocated++;
                if (next < 2 || (next >= clusters + 2 && next < 0x0ffffff8)) invalid++;
            }
        }
        if (bad != 0) issues.Add("FAT contains marked bad clusters");
        if (invalid != 0) issues.Add("FAT contains out-of-range/reserved cluster links");
        var info = new Dictionary<string, object>();
        if (infoSector > 0 && infoSector < reserved)
        {
            byte[] fsinfo = ReadAt(source, infoSector * 512L, 512);
            bool valid = U32(fsinfo, 0) == 0x41615252 && U32(fsinfo, 484) == 0x61417272
                      && U32(fsinfo, 508) == 0xaa550000;
            uint reportedFree = U32(fsinfo, 488);
            info["SignatureValid"] = valid;
            info["ReportedFreeClusters"] = reportedFree;
            info["CountedFreeClusters"] = free;
            info["NextFreeHint"] = U32(fsinfo, 492);
            if (!valid) issues.Add("Invalid FSInfo signatures");
            if (reportedFree != uint.MaxValue && reportedFree != free)
                issues.Add("FSInfo free-cluster count differs from FAT (may be a stale hint)");
        }
        int clusterBytes = perCluster * 512;
        var rootChain = Chain(root, fat, clusters);
        var directory = ReadChain(source, rootChain, dataSector * 512, clusterBytes);
        var entries = new List<object>();
        var owners = new HashSet<uint>(rootChain);
        bool pianoFound = false;
        for (int at = 0; at + 32 <= directory.Length && directory[at] != 0; at += 32)
        {
            byte attr = directory[at + 11];
            if (directory[at] == 0xe5 || attr == 0x0f || (attr & 8) != 0) continue;
            string baseName = Encoding.ASCII.GetString(directory, at, 8).TrimEnd();
            string extension = Encoding.ASCII.GetString(directory, at + 8, 3).TrimEnd();
            string name = baseName + (extension.Length == 0 ? "" : "." + extension);
            uint first = ((uint)U16(directory, at + 20) << 16) | U16(directory, at + 26);
            uint length = U32(directory, at + 28);
            bool isDirectory = (attr & 16) != 0;
            var entry = new Dictionary<string, object> {
                {"ShortName", name}, {"Attributes", attr}, {"Directory", isDirectory},
                {"FirstCluster", first}, {"Bytes", length}
            };
            if (first >= 2)
            {
                var chain = Chain(first, fat, clusters);
                entry["Clusters"] = chain.ToArray();
                entry["FirstPhysicalLba"] = startLba + dataSector + (first - 2L) * perCluster;
                foreach (uint cluster in chain)
                    if (!owners.Add(cluster)) issues.Add("Cross-linked root entry: " + name);
                if (!isDirectory)
                {
                    long needed = (length + clusterBytes - 1L) / clusterBytes;
                    if (chain.Count != needed) issues.Add("File chain length differs from size: " + name);
                    if (name == "PIANO.BIN")
                    {
                        pianoFound = true;
                        byte[] data = ReadChain(source, chain, dataSector * 512, clusterBytes);
                        if (data.Length < length) throw new InvalidDataException("Short PIANO.BIN chain");
                        Array.Resize(ref data, checked((int)length));
                        entry["RawChainSha256"] = Hash(data);
                        File.WriteAllBytes(Path.Combine(outputDir, "piano_from_fat.bin"), data);
                    }
                }
            }
            entries.Add(entry);
        }
        if (!pianoFound) issues.Add("PIANO.BIN missing from short-name root directory");
        return new Dictionary<string, object> {
            {"Boot", Describe(boot, 0, startLba)}, {"SectorBytes", sectorBytes},
            {"SectorsPerCluster", perCluster}, {"ReservedSectors", reserved}, {"FatCopies", fats},
            {"SectorsPerFat", fatSectors}, {"TotalSectors", total}, {"DataClusters", clusters},
            {"RootCluster", root}, {"RootPhysicalLba", startLba + dataSector + (root - 2L) * perCluster},
            {"FatCopyDifferingBytes", fatDifferences}, {"BackupBootMatches", backupMatches},
            {"FreeClusters", free}, {"AllocatedClusters", allocated}, {"MarkedBadClusters", bad},
            {"InvalidFatLinks", invalid}, {"CleanShutdownFlag", (U32(fat, 4) & 0x08000000) != 0},
            {"NoRecordedIoErrorFlag", (U32(fat, 4) & 0x04000000) != 0},
            {"FsInfo", info}, {"RootEntries", entries}
        };
    }

    public static Dictionary<string, object> Run(string device, long size, long startLba, string outputDir)
    {
        Directory.CreateDirectory(outputDir);
        var issues = new List<string>();
        var report = new Dictionary<string, object> {
            {"Device", device}, {"ReadOnly", true}, {"VolumeBytes", size}, {"VolumeStartLba", startLba},
            {"Scope", "Entire partition through Windows volume handle; no raw physical-disk access"},
            {"Limitations", "Reads may use OS/reader caches. No write/capacity test or SPI-mode test."}
        };
        var firstHashes = new List<string>();
        var passes = new List<object>();
        var sectorMatches = new List<object>();
        var windowMatches = new List<object>();
        var capturedOffsets = new List<long>();
        var keys = new List<long> {0, 512, 6 * 512, 7 * 512, 32 * 512, (size / 512 - 1) * 512};
        var firstKeys = new Dictionary<long, string>();
        const int blockBytes = 4 * 1024 * 1024;
        byte[] buffer = new byte[blockBytes];
        for (int pass = 0; pass < 2; pass++)
        {
            long position = 0, nextProgress = 0;
            int block = 0, differentBlocks = 0;
            var hashes = new List<string>();
            var timer = Stopwatch.StartNew();
            byte[] overlap = new byte[511];
            try
            {
            using (var source = new FileStream(device, FileMode.Open, FileAccess.Read,
                                               FileShare.ReadWrite, 4096, FileOptions.SequentialScan))
            using (var sha = SHA256.Create())
            {
                if (pass == 0)
                {
                    try { report["FileSystem"] = FileSystem(source, size, startLba, outputDir, issues); }
                    catch (Exception error) { issues.Add("Filesystem check: " + error.Message); }
                }
                foreach (long key in keys)
                {
                    try
                    {
                        string hash = Hash(ReadAt(source, key, 512));
                        if (pass == 0) firstKeys[key] = hash;
                        else if (firstKeys.ContainsKey(key) && firstKeys[key] != hash)
                            issues.Add("Key-sector repeat mismatch at byte " + key);
                    }
                    catch (Exception error) { issues.Add("Key-sector read at " + key + ": " + error.Message); }
                }
                source.Position = 0;
                while (position < size)
                {
                    int length = (int)Math.Min(blockBytes, size - position);
                    int received = 0;
                    try
                    {
                        while (received < length)
                        {
                            int count = source.Read(buffer, received, length - received);
                            if (count == 0) throw new EndOfStreamException("Short read");
                            received += count;
                        }
                    }
                    catch (Exception error)
                    {
                        issues.Add("Read failure, pass " + (pass + 1) + " byte " + (position + received)
                                   + ": " + error.Message);
                        Console.WriteLine(issues[issues.Count - 1]);
                        break;
                    }
                    sha.TransformBlock(buffer, 0, length, buffer, 0);
                    string blockHash;
                    using (var blockSha = SHA256.Create())
                        blockHash = Hex(blockSha.ComputeHash(buffer, 0, length));
                    hashes.Add(blockHash);
                    if (pass == 0)
                    {
                        firstHashes.Add(blockHash);
                        for (int at = 0; at + 512 <= length; at += 512)
                            if (buffer[at + 510] == 0x2a && buffer[at + 511] == 0xbf)
                            {
                                byte[] sector = new byte[512];
                                Array.Copy(buffer, at, sector, 0, 512);
                                sectorMatches.Add(Describe(sector, position + at, startLba));
                            }
                        // Search every 512-byte window, including those crossing read blocks.
                        for (int at = (position == 0 ? 0 : -511); at + 511 < length; at++)
                        {
                            byte first = at < 0 ? overlap[511 + at] : buffer[at];
                            if (first != 0x88) continue;
                            int last = at + 511;
                            byte penultimate = last == 0 ? overlap[510] : buffer[last - 1];
                            if (penultimate == 0x2a && buffer[last] == 0xbf)
                            {
                                long offset = position + at;
                                if (capturedOffsets.Count < 256) capturedOffsets.Add(offset);
                            }
                        }
                        Array.Copy(buffer, length - 511, overlap, 0, 511);
                    }
                    else if (block >= firstHashes.Count || firstHashes[block] != blockHash)
                    {
                        differentBlocks++;
                        issues.Add("Repeated full-read mismatch at volume byte " + position);
                    }
                    position += length;
                    block++;
                    if (position >= nextProgress || position == size)
                    {
                        Console.WriteLine("Read pass {0}/2: {1:F1}% ({2}/{3} bytes), {4:F1}s",
                            pass + 1, 100.0 * position / size, position, size, timer.Elapsed.TotalSeconds);
                        nextProgress = position + 64 * 1024 * 1024;
                    }
                }
                sha.TransformFinalBlock(new byte[0], 0, 0);
                passes.Add(new Dictionary<string, object> {
                    {"Pass", pass + 1}, {"BytesRead", position}, {"Complete", position == size},
                    {"Sha256", Hex(sha.Hash)}, {"DifferingBlocks", differentBlocks},
                    {"Seconds", timer.Elapsed.TotalSeconds}, {"BlockBytes", blockBytes},
                    {"BlockSha256", hashes.ToArray()}
                });
            }
            }
            catch (Exception error) { issues.Add("Pass " + (pass + 1) + ": " + error.Message); }
        }
        try
        {
        using (var source = new FileStream(device, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            foreach (long offset in capturedOffsets)
            {
                long aligned = offset / 512 * 512;
                int skip = (int)(offset - aligned);
                byte[] surrounding = ReadAt(source, aligned, skip == 0 ? 512 : 1024);
                byte[] window = new byte[512];
                Array.Copy(surrounding, skip, window, 0, 512);
                windowMatches.Add(Describe(window, offset, startLba));
                File.WriteAllBytes(Path.Combine(outputDir, "match_" + offset + ".bin"), window);
            }
        }
        }
        catch (Exception error) { issues.Add("Match capture: " + error.Message); }
        report["Passes"] = passes;
        report["SectorAligned2ABF"] = sectorMatches;
        report["AnyAlignment88_2ABF"] = windowMatches;
        report["Issues"] = issues.ToArray();
        return report;
    }
}
