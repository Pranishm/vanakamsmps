const nextConfig = {
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'res.cloudinary.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: '**.blob.vercel-storage.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'crafatar.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'minotar.net',
        pathname: '/**',
      },
      {
        protocol: 'http',
        hostname: 'localhost',
        pathname: '/**',
      },
    ],
  },
  serverExternalPackages: ['ssh2'],
  async redirects() {
    return [
      { source: '/tienda', destination: '/shop', permanent: true },
      { source: '/normas', destination: '/rules', permanent: true },
      { source: '/noticias', destination: '/news', permanent: true },
      { source: '/foro', destination: '/forum', permanent: true },
      { source: '/soporte', destination: '/support', permanent: true },
      { source: '/carrito', destination: '/cart', permanent: true },
      { source: '/perfil', destination: '/profile', permanent: true },
      { source: '/terminos', destination: '/terms', permanent: true },
      { source: '/privacidad', destination: '/privacy', permanent: true },
      { source: '/notificaciones', destination: '/notifications', permanent: true },
    ];
  },
  experimental: {
    // Other experimental features can go here
  },
}

module.exports = nextConfig
