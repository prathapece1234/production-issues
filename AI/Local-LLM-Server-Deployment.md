# Internal AI Server Deployment – Telvrix AI Platform

## Project Summary

Designed and automated the deployment of an internal AI development platform on Ubuntu Server using a single setup script.

The automation installs all required dependencies, configures the development environment, deploys local Large Language Models (LLMs) using Ollama, and prepares the application for internal users without relying on external cloud AI services.

---

## Objective

Deploy a self-hosted AI platform capable of:

- Running local LLMs
- Code generation
- AI chat
- Document processing
- Internal development assistance

without requiring external AI APIs.

---

## Environment

| Component | Details |
|----------|---------|
| Operating System | Ubuntu 22.04 LTS |
| Platform | Telvrix AI |
| Runtime | Python 3 |
| UI | Node.js 20 |
| AI Engine | Ollama |
| Models | qwen2.5-coder:7b, gemma4:e4b |

---

## Automation Overview

Developed a Bash automation script that performs end-to-end server provisioning.

The script automatically:

- Updates the operating system
- Installs development packages
- Installs Python dependencies
- Installs Node.js 20
- Builds the frontend
- Installs Ollama
- Downloads required AI models
- Creates application directories
- Generates environment configuration
- Prepares the application for production use

---

## Components Installed

### Operating System Packages

- Python 3
- pip
- Git
- Curl
- GCC
- Build Tools
- PostgreSQL development libraries

---

### Python Packages

Installed required AI and document processing libraries including:

- FastAPI
- Uvicorn
- HTTPX
- python-docx
- python-pptx
- OpenPyXL
- Matplotlib
- Pillow
- PyPDF2
- PDFPlumber
- FPDF2

---

### Node.js

Installed:

- Node.js v20
- npm

Used for building the frontend interface.

---

### AI Runtime

Installed Ollama and configured it as the local inference engine.

Automatically started the Ollama service after installation.

---

## AI Models

Downloaded and configured:

| Model | Purpose |
|--------|---------|
| qwen2.5-coder:7b | Code generation and software development |
| gemma4:e4b | Lightweight general-purpose AI assistant |

---

## Application Configuration

Automatically generated environment configuration.

Configured:

- API endpoint
- WebSocket endpoint
- AI model
- Workspace directory
- History directory
- Service port
- LLM timeout

---

## Directory Structure

Created application directories:

```

/opt/telvrix/workspaces
/opt/telvrix/history

```

Configured appropriate permissions for application access.

---

## Automation Features

- Fully automated installation
- Non-interactive package installation
- Automatic dependency resolution
- Automatic AI model download
- Automatic environment configuration
- Automatic directory creation
- Production-ready setup

---

## Validation

Verified:

- Python installation
- Node.js installation
- npm installation
- Ollama service
- AI model availability
- Environment configuration
- Application startup

Successfully launched the application and verified access through:

```

http://SERVER\_IP:3000/code

```

---

## Benefits

- Fully self-hosted AI platform
- No dependency on external AI APIs
- Local AI inference
- Automated deployment
- Reduced manual configuration
- Faster environment provisioning
- Consistent server configuration
- Suitable for internal development environments

---

## Technologies Used

- Ubuntu 22.04 LTS
- Bash
- Python
- FastAPI
- Node.js 20
- npm
- Ollama
- qwen2.5-coder
- Gemma
- Linux System Administration
- AI Infrastructure
- Automation

---

## Key Learnings

- Automated Linux server provisioning using Bash scripting.
- Deployed local LLMs without relying on cloud-based AI services.
- Integrated Python, Node.js, and Ollama into a unified deployment process.
- Simplified AI platform setup through a reusable installation script.
- Enabled secure, self-hosted AI capabilities for internal development teams.
