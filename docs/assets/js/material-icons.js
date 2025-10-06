/**
 * VelocityNvim - Material Icons Integration
 * Maps our icon names to Google Material Icons
 */

// Custom SVG Icons (nicht in Material Icons verfügbar)
import { Icons as CustomIcons } from './icons.js';

// Mapping: Unsere Icon-Namen → Material Icon Namen
const materialIconMap = {
    // UI & Actions
    'checkmark': 'check_circle',
    'checkmarkSimple': null,  // Custom - Simple checkmark without circle
    'clipboard': 'content_copy',
    'chart': 'bar_chart',
    'package': 'inventory_2',
    'design': 'palette',
    'lightning': 'bolt',
    'brain': 'psychology',
    'wrench': 'build',
    'document': 'description',
    'rocket': 'rocket_launch',
    'coffee': 'local_cafe',

    // Alerts
    'alertRed': 'error',
    'alertOrange': 'warning',

    // Social & Links
    'star': 'star',
    'bug': 'bug_report',
    'fork': 'call_split',
    'pullrequest': 'merge',
    'youtube': null,  // Custom - YouTube Logo
    'bell': 'notifications',
    'share': 'share',
    'book': 'menu_book',
    'chat': 'chat_bubble',

    // Flags (verwenden Custom SVG)
    'flagDE': null,  // Custom
    'flagUK': null,  // Custom

    // Tech Logos (verwenden Custom SVG - Original Logos)
    'bitcoin': null,      // Custom - Bitcoin Logo
    'archlinux': null,    // Custom - Arch Linux Logo
    'rust': null,         // Custom - Rust Logo
    'homebrew': null,     // Custom - Homebrew Logo
    'apple': 'desktop_mac', // Material Icons - Desktop Mac
};

/**
 * Rendert ein Icon (Material oder Custom)
 * @param {string} iconName - Icon-Name
 * @param {string} color - Farbe (nur für Custom Icons)
 * @param {string} size - Größe
 * @returns {string} HTML-String
 */
export function getIcon(iconName, color, size) {
    const materialName = materialIconMap[iconName];

    // Wenn Material Icon verfügbar, verwende es
    if (materialName) {
        const sizeValue = size || '24';
        const style = `font-size: ${sizeValue}px; color: ${color || '#0366d6'};`;
        return `<span class="material-symbols-outlined" style="${style}">${materialName}</span>`;
    }

    // Ansonsten verwende Custom SVG Icon
    const customIcon = CustomIcons[iconName];
    if (!customIcon) {
        console.warn(`Icon "${iconName}" not found`);
        return '';
    }

    // Custom Icon Logik (wie vorher)
    if (typeof customIcon === 'function') {
        if (color !== null && color !== undefined && size !== null && size !== undefined) {
            return customIcon(color, size);
        } else if (color !== null && color !== undefined) {
            return customIcon(color);
        } else if (size !== null && size !== undefined) {
            return customIcon(undefined, size);
        } else {
            return customIcon();
        }
    }
    return customIcon;
}

/**
 * Rendert alle Icons mit data-icon Attribut
 */
export function renderDataIcons() {
    document.querySelectorAll('[data-icon]').forEach(el => {
        const iconName = el.getAttribute('data-icon');
        const color = el.getAttribute('data-color');
        const size = el.getAttribute('data-size');
        el.innerHTML = getIcon(iconName, color, size);
    });
}
