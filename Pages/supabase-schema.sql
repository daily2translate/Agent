-- Blog Posts Table
CREATE TABLE IF NOT EXISTS posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author TEXT,
    slug TEXT UNIQUE,
    tags TEXT[],
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_slug ON posts(slug);

-- Enable Row Level Security (RLS)
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public read access to published posts
CREATE POLICY "Allow public read access to published posts"
    ON posts
    FOR SELECT
    USING (status = 'published');

-- Policy: Allow authenticated users to insert posts
CREATE POLICY "Allow authenticated users to insert posts"
    ON posts
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Allow authenticated users to update their own posts
CREATE POLICY "Allow authenticated users to update posts"
    ON posts
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample posts
INSERT INTO posts (title, content, author, tags, status) VALUES
    (
        'Welcome to My Blog!',
        'This is my first blog post powered by Supabase and GitHub Pages. I can now write posts and they will automatically appear on my website!',
        'Admin',
        ARRAY['welcome', 'first-post'],
        'published'
    ),
    (
        'How This Blog Works',
        'This blog uses GitHub Pages for hosting and Supabase PostgreSQL for data storage. The frontend is pure HTML/CSS/JavaScript, and it fetches posts dynamically from Supabase using their JavaScript client library.',
        'Admin',
        ARRAY['tech', 'architecture'],
        'published'
    ),
    (
        'n8n Integration Coming Soon',
        'Soon I will integrate n8n to automatically create blog posts from various sources. This will enable automated content publishing workflows!',
        'Admin',
        ARRAY['automation', 'n8n'],
        'published'
    );
