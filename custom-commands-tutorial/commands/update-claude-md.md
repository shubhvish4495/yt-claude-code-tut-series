Analyze the current codebase structure and update the CLAUDE.md file to accurately reflect the project architecture, dependencies, and usage instructions. This command ensures the CLAUDE.md file stays synchronized with the actual codebase.

**Purpose:**
Generate or update CLAUDE.md with comprehensive project documentation that helps Claude Code understand the codebase structure, build processes, dependencies, and common workflows.

**Process:**

1. **Codebase Analysis:**
   - **Directory Structure**: Use `find` and `tree` commands to map the complete directory structure
   - **File Types**: Identify all programming languages, configuration files, and documentation
   - **Key Files**: Locate main entry points, configuration files, package managers, build scripts
   - **Dependencies**: Analyze package.json, go.mod, requirements.txt, Cargo.toml, pom.xml, etc.
   - **Build System**: Identify Makefile, build scripts, CI/CD configurations

2. **Technology Stack Detection:**
   - **Programming Languages**: Determine primary and secondary languages used
   - **Frameworks**: Identify web frameworks, libraries, and tools
   - **Database**: Check for database configurations and migrations
   - **Testing**: Locate test files and testing frameworks
   - **Documentation**: Find existing README files, docs folders, API documentation

3. **Project Metadata Extraction:**
   - **Project Name**: Extract from package files or directory structure
   - **Version**: Find version information from package managers or tags
   - **Description**: Derive project purpose from existing documentation or code
   - **Author/Organization**: Extract from package files if available

4. **Architecture Analysis:**
   - **Entry Points**: Identify main files (main.go, index.js, app.py, etc.)
   - **Module Structure**: Map how code is organized (packages, modules, components)
   - **Configuration**: Document environment variables, config files, settings
   - **API Endpoints**: If applicable, document REST/GraphQL endpoints
   - **Database Schema**: If present, document data models and relationships

5. **Build and Development Workflow:**
   - **Installation**: Document dependency installation steps
   - **Building**: Identify build commands and processes
   - **Running**: Document how to start/run the application
   - **Testing**: Document test execution commands
   - **Deployment**: If configured, document deployment processes

6. **CLAUDE.md File Structure:**
   Create or update CLAUDE.md with these sections:
   ```markdown
   # CLAUDE.md

   ## Project Overview
   [Brief description, technology stack, purpose]

   ## Directory Structure
   [Visual representation of key directories and files]

   ## Dependencies
   [List of major dependencies and their purposes]

   ## Build System
   [Available build commands, scripts, and their purposes]

   ## Development Workflow
   [How to set up, develop, test, and deploy]

   ## Architecture
   [Key components, entry points, and how they interact]

   ## Configuration
   [Environment variables, config files, settings]

   ## Common Commands
   [Frequently used commands organized by category]

   ## Testing
   [How to run tests, test structure, coverage]

   ## Deployment
   [If applicable, deployment procedures and environments]
   ```

7. **Content Generation Guidelines:**
   - **Accuracy**: Only document what actually exists in the codebase
   - **Completeness**: Cover all major aspects of the project
   - **Clarity**: Use clear, concise language with practical examples
   - **Code Examples**: Include actual command examples and code snippets
   - **Maintenance**: Structure content to be easily maintainable
   - **Claude-Friendly**: Format information in a way that helps Claude understand the project quickly

8. **Validation Steps:**
   - **File Existence**: Verify all referenced files and directories exist
   - **Command Verification**: Test that documented commands actually work
   - **Completeness Check**: Ensure all major project aspects are covered
   - **Consistency**: Check that information aligns across all sections

9. **Update Strategy:**
   - **Existing File**: If CLAUDE.md exists, preserve valuable manual additions while updating structure/commands
   - **New File**: Create comprehensive documentation from scratch
   - **Backup**: Before major updates, preserve existing content
   - **Incremental**: Focus on areas that have changed since last update

10. **Special Considerations:**
    - **Sensitive Information**: Never include secrets, API keys, or credentials
    - **Dynamic Content**: Handle projects with generated or dynamic content appropriately
    - **Multi-Language Projects**: Document all language-specific workflows
    - **Microservices**: Handle complex multi-service architectures appropriately
    - **Legacy Code**: Document older codebases with appropriate context

**Output Requirements:**
- Create or update CLAUDE.md in the project root directory
- Ensure all sections are populated with accurate, current information
- Include practical examples and commands that actually work
- Structure content for easy navigation and quick reference
- Maintain consistency with existing documentation style if present