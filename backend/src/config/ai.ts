import Anthropic from '@anthropic-ai/sdk';

export const aiConfig = {
  model: process.env.AI_MODEL || 'claude-sonnet-4-20250514',
  maxTokens: parseInt(process.env.AI_MAX_TOKENS || '2048', 10),
};

let client: Anthropic | null = null;

export function getAnthropicClient(): Anthropic {
  if (!client) {
    client = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });
  }
  return client;
}
