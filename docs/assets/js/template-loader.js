/**
 * VelocityNvim Landing Page - Template Loader
 * Lädt alle Content-Templates und rendert Icons
 */

import { heroTemplate, featuresTemplate } from './templates/hero.js';
import { requirementsTemplate } from './templates/requirements.js';
import { installationTemplate } from './templates/installation.js';
import { supportTemplate } from './templates/support.js';
import { linksTemplate } from './templates/links.js';
import { getIcon, renderDataIcons } from './material-icons.js';

/**
 * Lädt alle Templates in die Content-Container
 */
export function loadTemplates() {
    // Hero & Features
    const heroContainer = document.getElementById('hero-container');
    if (heroContainer) {
        heroContainer.innerHTML = heroTemplate() + featuresTemplate();
    }

    // Requirements
    const requirementsContainer = document.getElementById('requirements-container');
    if (requirementsContainer) {
        requirementsContainer.innerHTML = requirementsTemplate();
    }

    // Installation
    const installationContainer = document.getElementById('installation-container');
    if (installationContainer) {
        installationContainer.innerHTML = installationTemplate();
    }

    // Support
    const supportContainer = document.getElementById('support-container');
    if (supportContainer) {
        supportContainer.innerHTML = supportTemplate();
    }

    // Links
    const linksContainer = document.getElementById('links-container');
    if (linksContainer) {
        linksContainer.innerHTML = linksTemplate();
    }

    // Render all data-icon attributes
    renderAllIcons();
}

/**
 * Rendert alle Icons mit data-icon Attributen
 */
function renderAllIcons() {
    renderDataIcons();
}

/**
 * Initialisiert Templates nach DOM-Load
 */
export function initializeTemplates() {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', loadTemplates);
    } else {
        loadTemplates();
    }
}
