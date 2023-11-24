import { sql } from '@vercel/postgres';

export default async function handler(request, response) {
  try {
    const result1 = await sql`
      CREATE TABLE wishlists (
        id SERIAL PRIMARY KEY,
        owner VARCHAR(255)
      );
    `;
    const result2 = await sql`
      CREATE TABLE wishes (
        id SERIAL PRIMARY KEY,
        content VARCHAR(255),
        wishlist_id INTEGER REFERENCES wishlists(id)
      );
    `;
    return response.status(200).json({ result1, result2 });
  } catch (error) {
    return response.status(500).json({ error });
  }
}
