//
//  GitignoreTemplates.swift
//  BRT Studio - Gitignore Templates
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

enum GitignoreTemplates {

    static let swift = """
    # Swift
    .build/
    DerivedData/
    *.xcodeproj/
    *.xcworkspace/
    xcuserdata/
    *.swiftpm
    .swiftpm/

    # SPM
    Packages/
    Package.resolved

    # Build artifacts
    *.app
    *.dSYM.zip
    *.dSYM
    """

    static let rust = """
    # Rust
    target/
    Cargo.lock
    **/*.rs.bk
    *.pdb

    # IDE
    .idea/
    .vscode/
    """

    static let python = """
    # Python
    __pycache__/
    *.py[cod]
    *$py.class
    *.so
    .Python
    build/
    develop-eggs/
    dist/
    downloads/
    eggs/
    .eggs/
    lib/
    lib64/
    parts/
    sdist/
    var/
    wheels/
    *.egg-info/
    .installed.cfg
    *.egg

    # Virtual environments
    venv/
    env/
    ENV/
    .venv/

    # Poetry
    poetry.lock

    # Testing
    .pytest_cache/
    .coverage
    htmlcov/
    """

    static let node = """
    # Node
    node_modules/
    npm-debug.log*
    yarn-debug.log*
    yarn-error.log*
    .npm
    .yarn/

    # Build
    dist/
    build/

    # Environment
    .env
    .env.local
    """
}
