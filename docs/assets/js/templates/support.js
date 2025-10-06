/**
 * VelocityNvim Landing Page - Support & Donation Template
 */

import { Icons } from '../icons.js';

export const supportTemplate = () => `
    <div id="support"></div>

    <!-- German Donation Section -->
    <div class="donation-section lang-content de active">
        <h2><span data-icon="coffee" data-size="36"></span>Unterstütze VelocityNvim</h2>
        <p style="font-size: 1.1em; margin-bottom: 10px;">
            Wenn dir VelocityNvim gefällt, unterstütze das Projekt!
        </p>

        <div class="support-grid">
            <div class="support-item bitcoin-item">
                <span class="emoji"><span data-icon="bitcoin" data-size="60"></span></span>
                <h3>Bitcoin Spende</h3>
                <p style="font-family: monospace; font-size: 0.85em; word-break: break-all; line-height: 1.3; margin-bottom: 10px;">bc1q6gmpgfn4wx2hx2c3njgpep9tl00etma9k7w6d4</p>
                <button class="copy-btn" onclick="copyBitcoinAddress('de')" title="Bitcoin-Adresse kopieren"><span data-icon="clipboard" data-size="16"></span> Kopieren</button>
                <div id="copy-feedback-de" class="copy-feedback">Kopiert! <span data-icon="checkmarkSimple" data-color="white" data-size="16"></span></div>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim">
                    <span class="emoji"><span data-icon="star" data-size="60"></span></span>
                    <div>
                        <h3>Repository starren</h3>
                        <p>Zeig deine Wertschätzung</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/issues">
                    <span class="emoji"><span data-icon="bug" data-size="60"></span></span>
                    <div>
                        <h3>Bugs melden</h3>
                        <p>Hilf Fehler zu finden</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/fork">
                    <span class="emoji"><span data-icon="fork" data-size="60"></span></span>
                    <div>
                        <h3>Code beitragen</h3>
                        <p>Pull Requests willkommen</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://www.youtube.com/@Maik-0000FF">
                    <span class="emoji"><span data-icon="youtube" data-size="60"></span></span>
                    <div>
                        <h3>YouTube-Kanal</h3>
                        <p>Installation & Setup</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <span class="emoji"><span data-icon="share" data-size="60"></span></span>
                <div>
                    <h3>Projekt teilen</h3>
                    <p>Erzähl anderen davon</p>
                </div>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/blob/main/README.md">
                    <span class="emoji"><span data-icon="book" data-size="60"></span></span>
                    <div>
                        <h3>Docs verbessern</h3>
                        <p>Dokumentation erweitern</p>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <!-- English Donation Section -->
    <div class="donation-section lang-content en">
        <h2><span data-icon="coffee" data-size="36"></span>Support VelocityNvim</h2>
        <p style="font-size: 1.1em; margin-bottom: 10px;">
            If you like VelocityNvim, support the project!
        </p>

        <div class="support-grid">
            <div class="support-item bitcoin-item">
                <span class="emoji"><span data-icon="bitcoin" data-size="60"></span></span>
                <h3>Bitcoin Donation</h3>
                <p style="font-family: monospace; font-size: 0.85em; word-break: break-all; line-height: 1.3; margin-bottom: 10px;">bc1q6gmpgfn4wx2hx2c3njgpep9tl00etma9k7w6d4</p>
                <button class="copy-btn" onclick="copyBitcoinAddress('en')" title="Copy Bitcoin address"><span data-icon="clipboard" data-size="16"></span> Copy</button>
                <div id="copy-feedback-en" class="copy-feedback">Copied! <span data-icon="checkmarkSimple" data-color="white" data-size="16"></span></div>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim">
                    <span class="emoji"><span data-icon="star" data-size="60"></span></span>
                    <div>
                        <h3>Star Repository</h3>
                        <p>Show your appreciation</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/issues">
                    <span class="emoji"><span data-icon="bug" data-size="60"></span></span>
                    <div>
                        <h3>Report Bugs</h3>
                        <p>Help find issues</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/fork">
                    <span class="emoji"><span data-icon="fork" data-size="60"></span></span>
                    <div>
                        <h3>Contribute Code</h3>
                        <p>Pull requests welcome</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <a href="https://www.youtube.com/@Maik-0000FF">
                    <span class="emoji"><span data-icon="youtube" data-size="60"></span></span>
                    <div>
                        <h3>YouTube Channel</h3>
                        <p>Installation & Setup</p>
                    </div>
                </a>
            </div>

            <div class="support-item">
                <span class="emoji"><span data-icon="share" data-size="60"></span></span>
                <div>
                    <h3>Share Project</h3>
                    <p>Tell others about it</p>
                </div>
            </div>

            <div class="support-item">
                <a href="https://github.com/Maik-0000FF/VelocityNvim/blob/main/README.md">
                    <span class="emoji"><span data-icon="book" data-size="60"></span></span>
                    <div>
                        <h3>Improve Docs</h3>
                        <p>Enhance documentation</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
`;
