import re
import os
import sys

# regex patterns
inst_pattern = re.compile(r'^\s*(\w+)\s*(#\s*\([^;]*?\))?\s+\w+\s*\(', re.MULTILINE)
package_pattern = re.compile(r'^\s*import\s+([A-Za-z_]\w*)::(\*|\w+)\s*;', re.MULTILINE)
interface_pattern = re.compile(
    r'(?<!\w)'                             # not part of larger word
    r'([A-Za-z_]\w*_if(?:\.[A-Za-z_]\w*)*)' # must contain "_if"
    r'\s+'                                 # whitespace
    r'([A-Za-z_]\w*)'                      # instance name
    #r'\s*(?=\(|,|;|\[)'                    # valid continuation
)

#module_def_pattern = re.compile(r'^\s*module\s+(\w+)', re.MULTILINE)
#package_pattern = re.compile(r'^\s*package\s+(\w+)', re.MULTILINE)
#interface_pattern = re.compile(r'^\s*interface\s+(\w+)', re.MULTILINE)

codebase_path = '..'
exceptions = ['sky130_sram_2kbyte_1rw1r_32x512_8']
# always_include = [f'{codebase_path}/src/CTRL/global_constants.svh']
header_files = [f'{codebase_path}/src/header_imports.svh']

def find_module_file(module_name, search_dirs):
    """Search for the file that defines a given module."""
    for dirpath in search_dirs:
        for fname in os.listdir(dirpath):
            if fname.endswith((".v", ".sv", ".svh")):
                fullpath = os.path.join(dirpath, fname)
                try:
                    with open(fullpath, 'r') as f:
                        content = f.read()
                        if re.search(rf'^\s*module\s+{module_name}\s*(#\s*\()?', content, re.MULTILINE) or re.search(rf'^\s*interface\s+{module_name}\b', content, re.MULTILINE) or re.search(rf'^\s*package\s+{module_name}\b', content, re.MULTILINE): 
                            return fullpath
                except Exception:
                    pass
    return None


def parse_file_for_instances(filename):
    """Return all submodules instantiated in a given file."""
    with open(filename, 'r') as f:
        text = f.read()

    instances = []

    for match in interface_pattern.finditer(text):
        module_name = match.group(1)
        if '.' in module_name:
            ind = module_name.index('.')
            module_name = module_name[:ind]
        #print(module_name)
        if module_name not in ["module", "endmodule", "input", "output", "wire", "reg"] + exceptions:
            instances.append(module_name)

    for match in package_pattern.finditer(text):
        module_name = match.group(1)
        #print(module_name)
        if module_name not in ["module", "endmodule", "input", "output", "wire", "reg"] + exceptions:
            instances.append(module_name)

    # collect all words that look like module instantiations
    for match in inst_pattern.finditer(text):
        module_name = match.group(1)
        if module_name not in ["module", "endmodule", "input", "output", "wire", "reg"] + exceptions:
            instances.append(module_name)
    return instances


def collect_hierarchy(top_file, search_dirs, seen=None):
    """Recursively collect all dependent module files starting from top."""
    if seen is None:
        seen = set()

    if top_file in seen:
        return []

    seen.add(top_file)
    hierarchy = [top_file]
    submodules = parse_file_for_instances(top_file)

    for sm in submodules:
        sub_file = find_module_file(sm, search_dirs)
        if sub_file and sub_file not in seen:
            #hierarchy.extend(collect_hierarchy(sub_file, search_dirs, seen)[0])
            hierarchy.extend(collect_hierarchy(sub_file, search_dirs, seen))
    #return hierarchy, seen
    return hierarchy

def find_search_dirs(base):
    ret = []
    for fname in os.listdir(base):
        absolute_dir = f"{base}/{fname}"
        if os.path.isdir(absolute_dir):
            ret.append(absolute_dir)
            ret += find_search_dirs(absolute_dir)
    return ret


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: get_rtl.py <top_module>", file=sys.stderr)
        sys.exit(1)

    top = sys.argv[1]
    #top = "user_project_wrapper"
    if os.path.isdir(f'{codebase_path}/packages'):
        search_dirs = [f'{codebase_path}/src', f'{codebase_path}/packages']
    else: 
        search_dirs = [f'{codebase_path}/src']
    search_dirs += find_search_dirs(f'{codebase_path}/src')
    top_file = find_module_file(top, search_dirs)

    #file_list, seen = collect_hierarchy(top_file, search_dirs)
    file_list = collect_hierarchy(top_file, search_dirs)
    #file_list3, seen = collect_hierarchy(header_files[0], search_dirs, seen)
    #file_list = file_list + file_list3
    file_list2 = []
    pkg = 0
    for f in reversed(file_list):
        if 'package' in f:
            file_list2.insert(pkg, f)
            pkg += 1
        elif '_if' in f:
            file_list2.insert(pkg, f)
        else:
            file_list2.append(f)

    # for f in always_include:
    #     file_list2.insert(pkg, f)
    #     pkg += 1

    with open('scripts/file_list.f', 'w') as f:
        for file in file_list2:
            f.write(f"{file}\n")

    print('scripts/file_list.f')
