from pathlib import Path
p=Path('tmp/ddr3/cone.py');s=p.read_text();start=s.index('    return set(re.findall(');end=s.index('\nfor m in inst:',start)
s=s[:start]+'''    declared=set(re.findall(r'^wire\\s+(?:\\[[^]]+\\]\\s+)?(\\S+)\\s*;',s,re.M))
    return set(re.findall(r'\\\\\\S+|\\b\\w+\\b',expr)) & declared
'''+s[end:];s=s.replace('GSR gsri(', 'GSR GSR(');p.write_text(s)
