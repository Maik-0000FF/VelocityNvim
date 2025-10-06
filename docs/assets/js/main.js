/**
 * VelocityNvim Landing Page - Main JavaScript
 * Event Handlers, Tab Switching, Language Toggle, Copy Functions
 */

import { Icons, getIcon } from './icons.js';
import { initializeTemplates } from './template-loader.js';

// ===== Mobile Menu Toggle =====
function toggleMobileMenu() {
    const navLinks = document.getElementById('navLinks');
    const hamburger = document.querySelector('.hamburger');
    navLinks?.classList.toggle('active');
    hamburger?.classList.toggle('active');
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    // Load all templates first
    initializeTemplates();

    // Setup nav links close on mobile
    const navLinks = document.querySelectorAll('.nav-links a');
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                document.getElementById('navLinks')?.classList.remove('active');
                document.querySelector('.hamburger')?.classList.remove('active');
            }
        });
    });

    // Load saved language preference
    const savedLang = localStorage.getItem('velocityLang');
    if (savedLang && savedLang === 'en') {
        switchLanguage('en');
    }
});

// ===== Tab Switching =====
function switchTab(tabName) {
    const tabContent = document.getElementById(tabName);
    if (!tabContent) return;

    const parentSection = tabContent.closest('.install-section');

    // Hide only tab contents within this section
    const contents = parentSection.querySelectorAll('.tab-content');
    contents.forEach(content => content.classList.remove('active'));

    // Remove active class from only tabs within this section
    const tabs = parentSection.querySelectorAll('.tab');
    tabs.forEach(tab => tab.classList.remove('active'));

    // Show selected tab content
    tabContent.classList.add('active');

    // Add active class to clicked tab
    event.target.classList.add('active');
}

function switchRequirementsTab(tabName) {
    switchTab(tabName);
}

function switchInstallTab(tabName) {
    switchTab(tabName);
}

// ===== Language Switching =====
function switchLanguage(lang) {
    // Hide all language content
    const langContents = document.querySelectorAll('.lang-content');
    langContents.forEach(content => content.classList.remove('active'));

    // Remove active class from all navigation language buttons
    const navLangBtns = document.querySelectorAll('.nav-lang-btn');
    navLangBtns.forEach(btn => btn.classList.remove('active'));

    // Show selected language content
    const selectedContents = document.querySelectorAll('.lang-content.' + lang);
    selectedContents.forEach(content => content.classList.add('active'));

    // Add active class to selected language button
    if (lang === 'de') {
        document.querySelectorAll('.nav-lang-btn')[0]?.classList.add('active');
    } else {
        document.querySelectorAll('.nav-lang-btn')[1]?.classList.add('active');
    }

    // Save language preference
    localStorage.setItem('velocityLang', lang);
}

// ===== Copy to Clipboard Functions =====
function copyBitcoinAddress(lang) {
    const address = 'bc1q6gmpgfn4wx2hx2c3njgpep9tl00etma9k7w6d4';
    const feedback = document.getElementById('copy-feedback-' + lang);

    copyToClipboard(address, feedback);
}

function copyOneliner(lang) {
    const onelinerElement = document.getElementById('oneliner-' + lang);
    const command = onelinerElement?.textContent;
    const feedback = document.getElementById('copy-feedback-oneliner-' + lang);

    if (command) {
        copyToClipboard(command, feedback);
    }
}

function copyToClipboard(text, feedbackElement) {
    // Modern clipboard API
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function() {
            showCopyFeedback(feedbackElement);
        }).catch(function(err) {
            console.error('Copy failed:', err);
            fallbackCopy(text, feedbackElement);
        });
    } else {
        fallbackCopy(text, feedbackElement);
    }
}

function fallbackCopy(text, feedbackElement) {
    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();

    try {
        document.execCommand('copy');
        showCopyFeedback(feedbackElement);
    } catch (err) {
        console.error('Fallback copy failed:', err);
    }

    document.body.removeChild(textarea);
}

function showCopyFeedback(feedbackElement) {
    if (!feedbackElement) return;

    feedbackElement.classList.add('show');
    setTimeout(function() {
        feedbackElement.classList.remove('show');
    }, 2000);
}


// ===== Export Functions for Global Access =====
window.toggleMobileMenu = toggleMobileMenu;
window.switchTab = switchTab;
window.switchRequirementsTab = switchRequirementsTab;
window.switchInstallTab = switchInstallTab;
window.switchLanguage = switchLanguage;
window.copyBitcoinAddress = copyBitcoinAddress;
window.copyOneliner = copyOneliner;
