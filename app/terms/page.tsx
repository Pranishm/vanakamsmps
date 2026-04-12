import PageHeader from '@/components/PageHeader';
import AnimatedSection from '@/components/AnimatedSection';
import Link from 'next/link';
import { cookies } from 'next/headers';
import { getLangFromCookieStore } from '@/lib/i18n';
import { Badge, Card } from '@/components/ui';

export default async function TermsPage() {
  const updatedAt = '2026-02-27';
  const cookieStore = await cookies();
  const lang = getLangFromCookieStore(cookieStore);

  const copy = {
    title: 'Terms & Conditions',
    desc: 'Read our terms of service',
    summary:
      'These terms govern the use of the Minecraft server and the website. If you disagree, please do not use the service.',
    sections: [
      {
        title: '1. Acceptance of Terms',
        body: <p>By accessing and using the server and website, you agree to these terms.</p>,
      },
      {
        title: '2. Code of Conduct',
        body: <p>You must follow server rules. Violations may result in sanctions, including suspensions or bans.</p>,
      },
      {
        title: '3. Purchases & Refunds',
        body: (
          <p>
            Generally, purchases are final. Ranks and products are non-refundable, except in exceptional cases determined by the administration.
          </p>
        ),
      },
      {
        title: '4. Privacy',
        body: (
          <p>
            We respect your privacy. See our{' '}
            <Link href="/privacy" className="underline">
              Privacy Policy
            </Link>
            .
          </p>
        ),
      },
      {
        title: '5. Changes',
        body: <p>We may update these terms when needed. Changes take effect once published on this page.</p>,
      },
      {
        title: '6. Prohibited Actions',
        body: (
          <ul>
            <li>Using hacks, unauthorized mods, or exploits</li>
            <li>Toxic behavior, harassment, or discrimination</li>
            <li>Spam or unauthorized advertising</li>
            <li>Unauthorized access attempts against the server or website</li>
          </ul>
        ),
      },
      {
        title: '7. Contact',
        body: <p>For questions about these terms, contact the administration through the ticket system.</p>,
      },
    ],
  };

  return (
    <div className="min-h-screen pt-24">
      <PageHeader
        title={copy.title}
        description={copy.desc}
      />

      <div className="container mx-auto px-4 py-12">
        <AnimatedSection>
          <div className="max-w-5xl mx-auto">
            <Card hover={false} className="p-5 sm:p-6">
              <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <Badge variant="info">Legal</Badge>
                    <Badge variant="default">Terms</Badge>
                  </div>
                  <p className="mt-3 text-sm text-gray-700 dark:text-gray-300">{copy.summary}</p>
                  <p className="mt-2 text-xs text-gray-500 dark:text-gray-400">
                    Last updated:{' '}
                    <span className="font-semibold">{updatedAt}</span>
                  </p>
                </div>

                <div className="shrink-0 text-xs text-gray-500 dark:text-gray-400">
                  See also:{' '}
                  <Link href="/privacy" className="underline">
                    Privacy
                  </Link>
                </div>
              </div>
            </Card>

            <div className="mt-6 space-y-4">
              {copy.sections.map((section) => (
                <Card key={section.title} hover={false} className="p-5 sm:p-6">
                  <div className="prose max-w-none dark:prose-invert">
                    <h2 className="mt-0">{section.title}</h2>
                    {section.body}
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </AnimatedSection>
      </div>
    </div>
  );
}
