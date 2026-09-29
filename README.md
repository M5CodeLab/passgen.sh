# 🔐 passgen.sh

**passgen.sh** is a lightweight, dependency-free Bash script that generates strong random passwords and random signed numbers (negative or positive, any number of digits).

Randomness comes directly from the operating system (`/dev/urandom`), so the output is cryptographically strong.

---

## ✨ Features

- Cryptographically secure randomness via `/dev/urandom`
- Adjustable password length and number of passwords
- Four generation modes: `full`, `alnum`, `number`, `mixed`
- Signed random numbers with an arbitrary number of digits (e.g. `-48213...` or `+90417...`)
- Guarantees each required character class appears at least once
- Quiet mode for scripts and pipes
- Colored output in the terminal
- Pure Bash, no external dependencies (only standard tools: `tr`, `head`)

---

## 📦 Installation

```bash
git clone https://github.com/M5CodeLab/passgen.sh.git
cd passgen.sh
chmod +x passgen.sh
```

Optional: install it system-wide.

```bash
sudo cp passgen.sh /usr/local/bin/passgen
```

---

## 🚀 Usage

```bash
./passgen.sh [-l LENGTH] [-c COUNT] [-m MODE] [-q] [-h]
```

| Option | Description | Default |
|--------|-------------|---------|
| `-l LENGTH` | Password length / number of digits (minimum 4) | `20` |
| `-c COUNT` | How many passwords to generate | `1` |
| `-m MODE` | Generation mode (see below) | `full` |
| `-q` | Quiet mode: print only the raw password | off |
| `-h` | Show help | – |

### Modes

| Mode | Output |
|------|--------|
| `full` | Letters + digits + symbols (`!@#$%^&*()_+=<>?-`) |
| `alnum` | Letters + digits only |
| `number` | A random signed integer (`-N … +N`) with any number of digits |
| `mixed` | Random characters followed by a random signed integer |

---

## 💡 Examples

```bash
# One 20-character password (default)
./passgen.sh

# Five 32-character passwords
./passgen.sh -l 32 -c 5

# Letters and digits only
./passgen.sh -m alnum -l 16

# A signed 50-digit random number
./passgen.sh -m number -l 50

# Mixed characters + signed number
./passgen.sh -m mixed -l 30

# Raw output only (useful in scripts)
./passgen.sh -q -l 24
```

Example output:

```
Password #1  (mode: full, length: 20)
  k#8Zr!aP2w_Qm7=Tx9Lb
```

### Use in scripts

```bash
PASSWORD=$(./passgen.sh -q -l 32)
echo "$PASSWORD"
```

---

## 🔒 Security Notes

- Uses `/dev/urandom`, the OS-provided cryptographic random source.
- Passwords are printed to the terminal — avoid using this on shared screens or in logs.
- Passwords are **not** stored anywhere by the script.

---

## 🖥️ Requirements

- Linux or macOS (any system with `/dev/urandom`)
- Bash 4+

---

## 🤝 Contributing

Issues and pull requests are welcome. Feel free to open an issue for bugs or feature ideas.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

**M5CodeLab** — [github.com/M5CodeLab](https://github.com/M5CodeLab)
