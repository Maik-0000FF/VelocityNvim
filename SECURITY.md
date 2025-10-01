# Security Policy

## 🔒 Reporting Security Vulnerabilities

We take the security of VelocityNvim seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Email:** maikblu.github@web.de

**Please include:**
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

### Response Time

- **Initial Response:** Within 48 hours
- **Status Updates:** Every 72 hours until resolved
- **Fix Timeline:** Depends on severity (Critical: <7 days, High: <14 days)

---

## 🛡️ Security Measures

VelocityNvim implements multiple security layers to protect critical assets:

### Protected Assets

The following files contain sensitive project information and require code owner approval for changes:

- **Landing Page** (`index.html`) - Project website with donation information
- **Documentation** (`README.md`) - Main documentation
- **Core Configuration** (`lua/core/*.lua`) - System configuration
- **Workflows** (`.github/workflows/*.yml`) - CI/CD automation

### Protection Mechanisms

1. **Code Owner Reviews Required**
   - Critical files require explicit approval from `@Maik-0000FF`
   - Defined in `.github/CODEOWNERS`

2. **Branch Protection Rules**
   - Pull requests required for `main` branch
   - No force pushes allowed
   - Code owner approval mandatory

3. **Automated Validation**
   - Pre-commit hooks for local validation
   - CI/CD checks on pull requests

4. **Automated Security Scanning**
   - CodeQL analysis for vulnerability detection
   - Weekly security scans
   - Real-time alerts for security issues

---

## 🔍 Automated Security

VelocityNvim uses automated security tools to maintain code quality:

### CodeQL Security Scanning

- **What it scans:** JavaScript/HTML code in landing page and workflows
- **Frequency:** On every push to main branch and weekly scheduled scans
- **Coverage:** XSS vulnerabilities, injection attacks, insecure patterns
- **Status:** [View Security Analysis](https://github.com/Maik-0000FF/VelocityNvim/security/code-scanning)

### Security Monitoring

All security findings are tracked through:
- GitHub Security tab with automated alerts
- Pull request checks preventing vulnerable code merges
- Weekly review of security scan results

---

## 📋 Supported Versions

| Version | Status           | Security Updates |
|---------|------------------|------------------|
| 1.0.x   | ✅ Stable Beta   | ✅ Active        |
| < 1.0   | ⚠️ Development   | ❌ Not supported |

---

## 🔐 Donation Address Security

VelocityNvim accepts Bitcoin donations. The official donation address is protected through multiple technical controls to prevent unauthorized modifications.

**Official Bitcoin Address:**
```
bc1q6gmpgfn4wx2hx2c3njgpep9tl00etma9k7w6d4
```

**Verification:**
- Always verify the address on our official GitHub repository
- Address is protected by code owner reviews
- Any unauthorized changes will be rejected automatically

**If you suspect the donation address has been compromised:**
- ⚠️ Do NOT send donations
- 📧 Report immediately to: maikblu.github@web.de
- 🐛 Create a GitHub issue with label `security`

---

## 🤝 Responsible Disclosure

We appreciate security researchers who follow responsible disclosure practices:

1. **Private Disclosure First:** Report vulnerabilities privately before public disclosure
2. **Reasonable Time:** Allow reasonable time for fixes before going public
3. **No Active Exploitation:** Do not exploit vulnerabilities beyond proof-of-concept
4. **Respect Privacy:** Do not access or modify other users' data

### Recognition

Security researchers who follow responsible disclosure will be:
- Acknowledged in release notes (if desired)
- Listed in our security acknowledgments
- Credited in commit messages

---

## 📞 Contact

- **Security Email:** maikblu.github@web.de
- **GitHub Issues:** [Report Security Issue](https://github.com/Maik-0000FF/VelocityNvim/issues/new?labels=security)
- **GitHub Discussions:** [Security Discussions](https://github.com/Maik-0000FF/VelocityNvim/discussions)

---

## 📜 Security Updates

Security updates and advisories will be published through:
- GitHub Security Advisories
- Repository releases with `security` tag
- `CHANGELOG.md` with security notes

**Stay informed:**
- Watch the repository for security updates
- Subscribe to release notifications
- Follow security tags in issues

---

**Last Updated:** 2025-10-01

**VelocityNvim Project** - Committed to security and transparency.
