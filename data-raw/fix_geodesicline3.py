#!/usr/bin/env python3
"""
Fix GeodesicLine3.cpp for R CMD check compliance.

This script:
1. Comments out #include <iostream>
2. Comments out all cout statements
3. Adds (void)0; no-op statements to empty if constexpr (debug) blocks

Usage:
    python3 fix_geodesicline3.py [path/to/GeodesicLine3.cpp]
    
If no path given, defaults to src/GeodesicLine3.cpp
"""

import sys
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Comment out #include <iostream>
    content = content.replace(
        '#include <iostream>',
        '// #include <iostream>  // R package: removed for R CMD check'
    )

    # 2. Comment out cout statements
    content = re.sub(r'^(\s*)(cout\s)', r'\1// \2', content, flags=re.MULTILINE)

    # 3. Comment out continuation lines starting with <<
    content = re.sub(r'^(\s*)(<<)', r'\1// \2', content, flags=re.MULTILINE)

    # 4. Add no-op to empty if constexpr (debug) blocks
    lines = content.split('\n')
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        result.append(line)
        
        # Check if this is an "if constexpr (debug)" line without a brace
        if 'if constexpr (debug)' in line and '{' not in line:
            # Look at next line - if it starts with // cout, add a no-op
            if i + 1 < len(lines) and '// cout' in lines[i + 1]:
                indent = len(line) - len(line.lstrip()) + 2
                result.append(' ' * indent + '(void)0; // R package: no-op for empty if block')
        i += 1

    with open(filepath, 'w') as f:
        f.write('\n'.join(result))

    print(f"Fixed {filepath}")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        filepath = sys.argv[1]
    else:
        filepath = 'src/GeodesicLine3.cpp'
    
    fix_file(filepath)
