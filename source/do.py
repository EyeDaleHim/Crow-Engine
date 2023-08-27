import os

def count_lines(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            trueLen = len(f.readlines())
            print(f"{file_path} length: {trueLen}")
            return trueLen
    except UnicodeDecodeError:
        print(f"Error: {file_path} is not encoded in UTF-8")
        return 0

def count_lines_recursive(directory):
    count = 0
    for root, dirs, files in os.walk(directory):
        for file_name in files:
            if file_name.endswith('.hx') or file_name.index('.') == -1:
                file_path = os.path.join(root, file_name)
                count += count_lines(file_path)
    return count

if __name__ == '__main__':
    directory_path = '.'
    line_count = count_lines_recursive(directory_path)
    print(f"Total number of lines in {directory_path}: {line_count}")