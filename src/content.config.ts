import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    date: z.date(),
    party: z.enum(['D', 'R']),
    state: z.string(),
    chamber: z.enum(['House', 'Senate']),
    tags: z.array(z.string()).default([]),
    sources: z.array(z.object({
      url: z.string(),
      label: z.string(),
    })).default([]),
    summary: z.string(),
  }),
});

export const collections = { blog };
