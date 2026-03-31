'use client';

import { useState, useRef, useEffect } from 'react';
import { Card, Button } from '@/components/ui';
import { toast } from 'react-toastify';
import { FaServer, FaTerminal, FaPlay, FaHeartbeat } from 'react-icons/fa';
import { useClientLang } from '@/lib/useClientLang';

export default function ServerControlPage() {
  const lang = useClientLang();
  const [starting, setStarting] = useState(false);
  const [logs, setLogs] = useState<string>('');
  const logsEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    logsEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [logs]);

  const startServer = async () => {
    setStarting(true);
    setLogs('');
    toast.info("Sending boot signal...");
    try {
      const response = await fetch('/api/start-server', { method: 'POST' });
      
      if (!response.body) throw new Error("No response body");
      const reader = response.body.getReader();
      const decoder = new TextDecoder();

      let done = false;
      while (!done) {
        const { value, done: readerDone } = await reader.read();
        done = readerDone;
        if (value) {
          const chunk = decoder.decode(value, { stream: true });
          setLogs((prev) => prev + chunk);
        }
      }
      toast.success("✅ Server process finished.");
    } catch (error) {
      toast.error("❌ Error starting server.");
      setLogs((prev) => prev + "\n[System] Failed to retrieve logs.");
    } finally {
      setStarting(false);
    }
  };

  const isSpanish = lang === 'es';

  return (
    <div className="space-y-6">
      <Card className="p-6 md:p-8 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-minecraft-grass/5 rounded-full blur-3xl pointer-events-none" />
        <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div className="grid h-10 w-10 place-items-center rounded-xl bg-minecraft-grass/10 text-minecraft-grass">
                <FaServer className="text-xl" />
              </div>
              <h2 className="text-xl font-bold dark:text-white text-gray-900">
                {isSpanish ? 'Control Principal' : 'Main Control'}
              </h2>
            </div>
            <p className="text-sm dark:text-gray-400 text-gray-600 max-w-xl">
              {isSpanish 
                ? 'Controla el encendido del servidor de Minecraft. Este proceso se ejecutará en segundo plano mediante un entorno seguro en tu máquina anfitriona.' 
                : 'Control the startup of the Minecraft server. This process will run in the background using a secure environment on your host machine.'}
            </p>
          </div>
          
          <div className="shrink-0 flex items-center gap-4">
            <Button 
              onClick={startServer} 
              disabled={starting}
              className="h-12 px-6 font-bold bg-minecraft-grass hover:bg-minecraft-grass/90 text-white shadow-lg shadow-minecraft-grass/20"
            >
              <FaPlay className={starting ? "animate-pulse" : ""} />
              <span className="ml-2">{starting ? (isSpanish ? 'Iniciando...' : 'Booting...') : (isSpanish ? 'Arrancar Servidor' : 'Start Server')}</span>
            </Button>
          </div>
        </div>
      </Card>

      {logs && (
        <Card className="p-0 overflow-hidden bg-[#0d1117] border-[#30363d] dark:bg-[#0d1117] dark:border-[#30363d] animate-fade-in">
          <div className="flex items-center justify-between px-4 py-2 border-b border-[#30363d] bg-[#161b22]">
            <div className="flex items-center gap-2">
              <FaTerminal className="text-gray-400 text-sm" />
              <span className="text-xs font-mono text-gray-400">vanakam-smp-boot</span>
            </div>
            <div className="flex gap-1.5">
              <div className="w-3 h-3 rounded-full bg-red-500/80"></div>
              <div className="w-3 h-3 rounded-full bg-yellow-500/80"></div>
              <div className="w-3 h-3 rounded-full bg-green-500/80"></div>
            </div>
          </div>
          <div className="p-4 h-64 overflow-y-auto font-mono text-[13px] leading-relaxed text-gray-300 whitespace-pre-wrap">
            {logs}
            <div ref={logsEndRef} />
          </div>
        </Card>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="p-6 relative overflow-hidden">
          <div className="absolute top-0 left-0 w-64 h-64 bg-blue-500/5 rounded-full blur-3xl pointer-events-none" />
          <div className="relative z-10">
            <h3 className="text-lg font-bold flex items-center gap-2 mb-4 dark:text-white text-gray-900">
              <FaTerminal className="text-blue-500" />
              {isSpanish ? 'Detalles Técnicos' : 'Technical Details'}
            </h3>
            <div className="space-y-4">
              <div className="bg-slate-50 dark:bg-slate-900/50 rounded-xl p-4 border border-slate-200 dark:border-white/5">
                <div className="text-xs text-slate-500 mb-1 uppercase tracking-wider font-semibold">
                  Script Path
                </div>
                <code className="text-sm text-slate-800 dark:text-slate-300 break-all">
                  /home/pranish/VanakamSMP/web_start.sh
                </code>
              </div>
              <div className="bg-slate-50 dark:bg-slate-900/50 rounded-xl p-4 border border-slate-200 dark:border-white/5">
                <div className="text-xs text-slate-500 mb-1 uppercase tracking-wider font-semibold">
                  Execution Context
                </div>
                <p className="text-sm text-slate-700 dark:text-slate-400">
                  {isSpanish 
                    ? 'El script se ejecuta utilizando el módulo built-in child_process de Node.js, aislando el proceso en una sesión terminal oculta que permite reinicios y acceso seguro desde SSH.'
                    : 'The script runs via Node builtin child_process module, detaching into a hidden terminal session that allows restarts and secure SSH access.'}
                </p>
              </div>
              <div className="bg-red-50 dark:bg-red-500/5 rounded-xl p-4 border border-red-100 dark:border-red-500/20">
                <div className="text-xs text-red-600 dark:text-red-400 mb-1 uppercase tracking-wider font-semibold">
                  Permissions Warning
                </div>
                <p className="text-sm text-red-700 dark:text-red-300">
                  {isSpanish 
                    ? 'Si el servidor falla al iniciar, asegúrate de que el script tiene permisos globales (chmod 777) en tu máquina Linux para que Node pueda invocarlo.'
                    : 'If the server fails to start, ensure the script has global execution permissions (chmod 777) on your Linux machine so Node can invoke it.'}
                </p>
              </div>
            </div>
          </div>
        </Card>

        <Card className="p-6 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-minecraft-diamond/5 rounded-full blur-3xl pointer-events-none" />
          <div className="relative z-10">
            <h3 className="text-lg font-bold flex items-center gap-2 mb-4 dark:text-white text-gray-900">
              <FaHeartbeat className="text-minecraft-diamond" />
              {isSpanish ? 'Estadísticas del Host' : 'Host Statistics'}
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-slate-50 dark:bg-slate-900/50 p-4 rounded-xl border border-slate-200 dark:border-white/5 flex flex-col items-center justify-center text-center">
                <div className="text-3xl font-bold text-slate-900 dark:text-white mb-1">
                  Node
                </div>
                <div className="text-xs text-slate-500 uppercase font-semibold">
                  Engine
                </div>
              </div>
              <div className="bg-slate-50 dark:bg-slate-900/50 p-4 rounded-xl border border-slate-200 dark:border-white/5 flex flex-col items-center justify-center text-center">
                <div className="text-3xl font-bold text-slate-900 dark:text-white mb-1">
                  100%
                </div>
                <div className="text-xs text-slate-500 uppercase font-semibold">
                  Integration
                </div>
              </div>
              <div className="col-span-2 bg-slate-50 dark:bg-slate-900/50 p-4 rounded-xl border border-slate-200 dark:border-white/5 relative overflow-hidden group border-t-2 border-t-minecraft-grass/50">
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-minecraft-grass/10 to-transparent -translate-x-full group-hover:animate-[shimmer_1.5s_infinite]" />
                <div className="text-sm font-medium text-slate-950 dark:text-slate-200 text-center">
                  VanakamSMP Service Node
                </div>
                <div className="text-xs text-slate-500 text-center mt-1">
                  {isSpanish ? 'Todo configurado y listo en la ruta base' : 'All systems configured and ready at base path'}
                </div>
              </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
