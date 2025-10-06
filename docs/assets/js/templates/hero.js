/**
 * VelocityNvim Landing Page - Hero & Features Template
 */

import { Icons } from '../icons.js';

export const heroTemplate = () => `
    <!-- German intro -->
    <p class="lang-content de active" style="text-align: center; font-size: 1.2em; margin-bottom: 20px;">
        Moderne, performante Neovim-Konfiguration ohne externe Plugin-Manager
    </p>
    <!-- English intro -->
    <p class="lang-content en" style="text-align: center; font-size: 1.2em; margin-bottom: 20px;">
        Modern, high-performance Neovim configuration without external plugin managers
    </p>

    <div style="text-align: center;">
        <a href="https://github.com/Maik-0000FF/VelocityNvim" class="cta-button lang-content de active">Zum GitHub Repository →</a>
        <a href="https://github.com/Maik-0000FF/VelocityNvim" class="cta-button lang-content en">Go to GitHub Repository →</a>
    </div>
`;

export const featuresTemplate = () => `
    <div id="features"></div>
    <h2 class="lang-content de active">Features</h2>
    <h2 class="lang-content en">Features</h2>

    <!-- German Features -->
    <ul class="features lang-content de active">
        <li><span data-icon="checkmark" data-size="20"></span>Eager Loading - Alle Plugins beim Start geladen für unterbrechungsfreien Workflow</li>
        <li><span data-icon="checkmark" data-size="20"></span>Native vim.pack Integration - keine externen Plugin-Manager</li>
        <li><span data-icon="checkmark" data-size="20"></span>Moderne LSP-Konfiguration mit vim.lsp.config</li>
        <li><span data-icon="checkmark" data-size="20"></span>Treesitter für Syntax-Highlighting</li>
        <li><span data-icon="checkmark" data-size="20"></span>fzf-lua für Fuzzy Finding (Rust-Performance)</li>
        <li><span data-icon="checkmark" data-size="20"></span>blink.cmp mit Rust fuzzy matching</li>
    </ul>

    <!-- English Features -->
    <ul class="features lang-content en">
        <li><span data-icon="checkmark" data-size="20"></span>Eager Loading - All plugins loaded at startup for uninterrupted workflow</li>
        <li><span data-icon="checkmark" data-size="20"></span>Native vim.pack integration - no external plugin managers</li>
        <li><span data-icon="checkmark" data-size="20"></span>Modern LSP configuration with vim.lsp.config</li>
        <li><span data-icon="checkmark" data-size="20"></span>Treesitter for syntax highlighting</li>
        <li><span data-icon="checkmark" data-size="20"></span>fzf-lua for fuzzy finding (Rust performance)</li>
        <li><span data-icon="checkmark" data-size="20"></span>blink.cmp with Rust fuzzy matching</li>
    </ul>
`;
