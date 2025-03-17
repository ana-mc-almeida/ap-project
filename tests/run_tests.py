import os
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

# Diretórios
tests_dir = "./"


def run_julia_test(test_file):
    result = subprocess.run(["julia", test_file], capture_output=True, text=True)
    if result.stderr.startswith("ERROR: LoadError:"):
        result.stderr = "ERROR:" + result.stderr[len("ERROR: LoadError:") :]
    return result.stdout.strip(), result.stderr.strip()


def read_file(file_path):
    with open(file_path, "r") as file:
        return file.read().strip()


def filter_error_message(stderr):
    if stderr:
        error_lines = stderr.split("\n")
        return error_lines[0]
    return ""


def save_test_result(folder_path, test_name, content):
    output_file = os.path.join(folder_path, f"{test_name}.myout")
    with open(output_file, "w") as f:
        f.write(content)


def run_test(root, test_file):
    test_name = test_file.split(".")[0]
    test_file_path = os.path.join(root, test_file)
    expected_output_path = os.path.join(root, f"{test_name}.out")

    if not os.path.exists(expected_output_path):
        return test_name, False

    expected_output = read_file(expected_output_path)
    stdout, stderr = run_julia_test(test_file_path)
    filtered_stderr = filter_error_message(stderr)

    real_output = stdout + (
        "\n" + filtered_stderr if stdout and filtered_stderr else filtered_stderr
    )

    save_test_result(root, test_name, real_output)

    return test_name, expected_output == real_output


def run_tests_in_folder(folder_path):
    total_tests = 0
    passed_tests = 0
    failed_tests = []

    test_files = [
        f for f in os.listdir(folder_path) if f.endswith(".jl") and f.startswith("test")
    ]
    total_tests = len(test_files)

    with ThreadPoolExecutor() as executor:
        futures = {
            executor.submit(run_test, folder_path, test_file): test_file
            for test_file in test_files
        }
        for future in as_completed(futures):
            test_name, passed = future.result()
            if passed:
                passed_tests += 1
            else:
                failed_tests.append(test_name)

    folder_name = os.path.basename(folder_path)
    print(
        f"\nRelatório de Testes para a pasta '{folder_name}': {passed_tests}/{total_tests}"
    )
    if failed_tests:
        print("Testes que falharam:")
        for test in failed_tests:
            print(f"- {test}")

    return total_tests, passed_tests, failed_tests


def run_all_tests():
    print("Running tests...")
    for root, dirs, files in os.walk(tests_dir):
        if root != tests_dir:
            run_tests_in_folder(root)
    print("\nAll tests completed.")


if __name__ == "__main__":
    run_all_tests()
