def solve(s):
  if 0 in s:
    p = len(s) - 1 - s[::-1].index(0);
    return 1 + solve([1 - i for i in s[0:p]]);
  else:
    return 0

def solves(s):
  return solve([ 0 if c == '-' else 1 for c in list(s) if c == '-' or c == '+' ])


fn = "B-small-attempt0";
with open ("/tmp/" + fn + ".in", 'r') as fin: 
  with open ("/tmp/" + fn + ".out", 'w') as fout: 
    lines = int(fin.readline())
    for i in range(1,lines+1):
      fout.write("Case #" + str(i) + ": "+ str(solves(fin.readline())) + "\n")

