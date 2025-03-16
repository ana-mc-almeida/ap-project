import os
import subprocess

# Diretórios
tests_dir = "./"


# Função para correr os testes Julia
def run_julia_test(test_file):
    # Chama o script Julia e captura a saída
    result = subprocess.run(["julia", test_file], capture_output=True, text=True)

    # Remover 'LoadError: ' do início da mensagem de erro, se houver
    if result.stderr.startswith("ERROR: LoadError:"):
        result.stderr = "ERROR:" + result.stderr[len("ERROR: LoadError:") :]

    return result.stdout.strip(), result.stderr.strip()


# Função para ler o conteúdo de um arquivo
def read_file(file_path):
    with open(file_path, "r") as file:
        return file.read().strip()


# Função para comparar as saídas
def compare_outputs(expected, actual):
    return expected == actual


# Função para filtrar e extrair apenas a mensagem de erro (sem o stack trace)
def filter_error_message(stderr):
    # Se o stderr contiver um stack trace, vamos pegar apenas a última linha com a mensagem de erro.
    if stderr:
        # Divida o erro em linhas e retorne apenas a primeira linha (mensagem do erro)
        error_lines = stderr.split("\n")
        return error_lines[0]  # Retorna apenas a primeira linha do erro
    return ""


# Função para salvar o resultado do teste
def save_test_result(folder_path, test_name, stdout, stderr):
    output_file = os.path.join(folder_path, f"{test_name}.myout")
    with open(output_file, "w") as f:
        if stdout:
            f.write(stdout)
            if stderr:
                f.write("\n")
        # Se houver erro, adicione a mensagem de erro (sem stack trace)
        if stderr:
            # f.write("\n\nErros:\n")
            f.write(stderr)
    return output_file


# Função para rodar todos os testes em uma pasta específica
def run_tests_in_folder(folder_path):
    total_tests = 0
    passed_tests = 0
    failed_tests = []

    # Itera por todos os arquivos .jl na pasta de testes
    for root, dirs, files in os.walk(folder_path):
        for test_file in files:
            if test_file.endswith(".jl") and test_file.startswith("test"):
                test_name = test_file.split(".")[0]  # Remove a extensão .jl

                # Caminhos dos arquivos
                test_file_path = os.path.join(root, test_file)
                expected_output_path = os.path.join(root, f"{test_name}.out")

                # Lê o resultado esperado
                expected_output = read_file(expected_output_path)

                # Executa o teste Julia
                stdout, stderr = run_julia_test(test_file_path)

                # Filtra a mensagem de erro, se existir
                filtered_stderr = filter_error_message(stderr)

                # Salva o resultado do teste
                output_file = save_test_result(
                    folder_path, test_name, stdout, filtered_stderr
                )
                real_output = read_file(output_file)

                # Compara a saída esperada com a saída real
                total_tests += 1
                if compare_outputs(expected_output, real_output):
                    passed_tests += 1
                else:
                    failed_tests.append(test_name)

    # Relatório de testes para a pasta
    folder_name = os.path.basename(folder_path)
    print(
        f"\nRelatório de Testes para a pasta '{folder_name}': {passed_tests}/{total_tests}"
    )
    if failed_tests:
        print("Testes que falharam:")
        for test in failed_tests:
            print(f"- {test}")

    return total_tests, passed_tests, failed_tests


# Função principal para rodar todos os testes em todas as subpastas
def run_all_tests():
    print("Running tests...")
    # Itera pelas subpastas dentro de 'tests' (também inclui a própria pasta 'tests')
    for root, dirs, files in os.walk(tests_dir):
        if root != tests_dir:  # Ignora a pasta 'tests' principal
            total_tests, passed_tests, failed_tests = run_tests_in_folder(root)

    print("\nAll tests completed.")


if __name__ == "__main__":
    run_all_tests()
