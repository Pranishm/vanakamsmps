const nextConfig = {
  images: {
    unoptimized: true,
    domains: ['localhost', 'crafatar.com', 'minotar.net', 'res.cloudinary.com'],
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
    ],
  },
  experimental: {
    turbopack: {
      root: '.',
    },
  },
}

module.exports = nextConfig
