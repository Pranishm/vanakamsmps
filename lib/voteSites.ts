export type VoteSite = {
  name: string;
  url: string;
  description?: string;
};

// Add your server's voting page URLs here.
// Replace the URLs below with your actual server listing links.
export const VOTE_SITES: VoteSite[] = [
  {
    name: 'MinecraftServers.org',
    url: 'https://minecraftservers.org/vote/684433',
    description: 'Vote and help us rank higher!',
  },
  {
    name: 'Minecraft-Server-List',
    url: 'https://minecraft-server-list.com/server/518331/vote/',
    description: 'Vote on MC Server List',
  },
  {
    name: 'TopMinecraftServers',
    url: 'https://topminecraftservers.org/',
    description: 'Top Minecraft Servers ranking',
  },
  {
    name: 'Planet Minecraft',
    url: 'https://www.planetminecraft.com/servers/',
    description: 'Vote on Planet Minecraft',
  },
];
