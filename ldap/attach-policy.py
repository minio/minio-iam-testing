import subprocess

for i in range(1, 401):
    group_cn = f"cn=project{i},ou=groups,ou=swengg,dc=min,dc=io"
    command = [
        "mc", "idp", "ldap", "policy", "attach",
        "myminio", "readwrite",
        f"--group={group_cn}"
    ]
    print(f"Running: {' '.join(command)}")
    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode == 0:
        print(f"Success: {result.stdout.strip()}")
    else:
        print(f"Error: {result.stderr.strip()}")

print("All commands are executed.")

