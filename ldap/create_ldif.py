output_file = "groups.ldif"

with open(output_file, "w") as f:
    for i in range(110,401):
        group_cn = f"project{i}"
        ldif_entry = f"""dn: cn={group_cn},ou=groups,ou=swengg,dc=min,dc=io
objectClass: groupOfNames
cn: {group_cn}
description: Project {i} group members
member: uid=dillon,ou=people,ou=swengg,dc=min,dc=io

"""
        f.write(ldif_entry)

print(f"LDIF file '{output_file}' generated successfully!")
