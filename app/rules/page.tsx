'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { FaBook, FaChevronDown, FaChevronUp } from 'react-icons/fa';
import PageHeader from '@/components/PageHeader';
import { Card } from '@/components/ui';
import { t } from '@/lib/i18n';
import { useClientLang } from '@/lib/useClientLang';

export default function NormasPage() {
  const lang = useClientLang();
  const [openSection, setOpenSection] = useState<number | null>(0);

  const content = {
          pageTitle: 'Server Rules',
          pageDesc: 'Read and follow our rules to keep a healthy community',
          serverTitle: '📜 Server Rules',
          discordTitle: '💬 Discord Rules',
          consequencesTitle: '⚖️ Consequences',
          noteTitle: '⚠️ Important note:',
          note:
            'Staff reserves the right to apply penalties based on context and severity. Rules may be updated at any time.',
          normasServidor: [
            {
              title: 'Respect and behavior',
              rules: [
                'Harassment, discrimination or offensive language is not allowed',
                'Respect all players and staff',
                'No chat spam',
                'No advertising other servers',
                'Keep a positive environment',
              ],
            },
            {
              title: 'Fair play',
              rules: [
                'No hacks, cheating mods or exploits',
                'Xray, fly hacks or kill aura are not allowed',
                "Don't abuse server bugs",
                'Report any bug you find',
                'Do not intentionally create lag',
              ],
            },
            {
              title: 'Building and griefing',
              rules: [
                'No griefing in protected areas',
                "Respect other players' builds",
                'Do not steal from unprotected chests (considered a severe offense)',
                'Keep your builds appropriate',
                'Do not build close to others without permission',
              ],
            },
            {
              title: 'Economy and trading',
              rules: [
                'Do not scam other players',
                'Honor trading agreements',
                'Do not manipulate the market',
                'Report scams to staff',
                'Transactions are your responsibility',
              ],
            },
            {
              title: 'Chat and communication',
              rules: [
                'Do not share personal information',
                'No external links without authorization',
                'Use the appropriate channels',
                'Primary language is English',
              ],
            },
          ],
          normasDiscord: [
            {
              title: 'General Discord rules',
              rules: [
                'Respect all members',
                'Use the appropriate channels for each topic',
                'No spam or mass mentions',
                'Follow Discord rules',
              ],
            },
            {
              title: 'Support and tickets',
              rules: [
                'One ticket per person',
                'Be clear and specific about your issue',
                'Provide evidence if needed',
                'Be patient while waiting for a response',
                'Do not open multiple tickets about the same topic',
              ],
            },
          ],
          consecuencias: [
            { infraccion: '1st minor offense', consecuencia: 'Warning 1' },
            { infraccion: '2nd minor offense', consecuencia: 'Warning 2' },
            { infraccion: '3rd minor offense', consecuencia: 'Temporary mute (1-24 hours)' },
            { infraccion: '1st major offense', consecuencia: 'Temporary ban (1-7 days)' },
            { infraccion: '2nd major offense', consecuencia: 'Temporary ban (7-30 days)' },
            { infraccion: 'Severe offense', consecuencia: 'Permanent ban' },
          ],
        };

  const RuleSection = ({ 
    title, 
    rules, 
    index 
  }: { 
    title: string; 
    rules: string[]; 
    index: number 
  }) => {
    const isOpen = openSection === index;

    return (
      <Card className="mb-4">
        <button
          onClick={() => setOpenSection(isOpen ? null : index)}
          className="w-full flex items-center justify-between text-left"
        >
          <h3 className="text-xl font-bold text-gray-900 dark:text-white">{title}</h3>
          {isOpen ? (
            <FaChevronUp className="text-minecraft-grass" />
          ) : (
            <FaChevronDown className="text-gray-400" />
          )}
        </button>

        {isOpen && (
          <motion.ul
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="mt-4 space-y-2"
          >
            {rules.map((rule, i) => (
              <li key={i} className="flex items-start space-x-3 text-gray-700 dark:text-gray-300">
                <span className="text-minecraft-grass font-bold mt-1">•</span>
                <span>{rule}</span>
              </li>
            ))}
          </motion.ul>
        )}
      </Card>
    );
  };

  return (
    <div className="py-20 px-4 sm:px-6 lg:px-8 max-w-4xl mx-auto">
      <PageHeader
        title={content.pageTitle}
        description={content.pageDesc}
        icon={<FaBook className="text-6xl text-minecraft-grass" />}
      />

      {/* Normas del Servidor */}
      <section className="mb-12">
        <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-6">{content.serverTitle}</h2>
        {content.normasServidor.map((section, index) => (
          <RuleSection
            key={index}
            title={section.title}
            rules={section.rules}
            index={index}
          />
        ))}
      </section>

      {/* Normas de Discord */}
      <section className="mb-12">
        <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-6">{content.discordTitle}</h2>
        {content.normasDiscord.map((section, index) => (
          <RuleSection
            key={index + content.normasServidor.length}
            title={section.title}
            rules={section.rules}
            index={index + content.normasServidor.length}
          />
        ))}
      </section>

      {/* Consecuencias */}
      <section>
        <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-6">{content.consequencesTitle}</h2>
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-700">
                  <th className="text-left py-3 px-4 text-minecraft-grass">{t(lang, 'rules.offense')}</th>
                  <th className="text-left py-3 px-4 text-minecraft-grass">{t(lang, 'rules.consequence')}</th>
                </tr>
              </thead>
              <tbody>
                {content.consecuencias.map((item, index) => (
                  <tr key={index} className="border-b border-gray-800 last:border-0">
                    <td className="py-3 px-4 text-gray-900 dark:text-white">{item.infraccion}</td>
                    <td className="py-3 px-4 text-gray-700 dark:text-gray-300">{item.consecuencia}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>

        <Card className="mt-6 bg-minecraft-redstone/10 border-minecraft-redstone">
          <p className="text-gray-900 dark:text-white">
            <strong>{content.noteTitle}</strong> {content.note}
          </p>
        </Card>
      </section>
    </div>
  );
}
