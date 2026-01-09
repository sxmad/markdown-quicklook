jest.mock('mermaid', () => ({
  initialize: jest.fn(),
  render: jest.fn().mockResolvedValue({ svg: '<svg>mocked diagram</svg>' }),
}));

// We import the index file to trigger the side-effect of setting window.renderMarkdown
import '../src/index';
import mermaid from 'mermaid'; // This will be the mocked version

describe('Markdown Renderer', () => {
  beforeEach(() => {
    // Setup the DOM element that index.ts expects
    document.body.innerHTML = '<div id="markdown-preview"></div>';
    jest.clearAllMocks();
  });

  test('should render mermaid diagram using mermaid.render API', async () => {
    const markdown = `
# Title
\`\`\`mermaid
graph TD;
    A-->B;
\`\`\`
    `;

    await window.renderMarkdown(markdown);

    const preview = document.getElementById('markdown-preview');
    expect(preview).toBeTruthy();
    
    const mermaidDiv = preview?.querySelector('.mermaid');
    expect(mermaidDiv).toBeTruthy();
    expect(mermaidDiv?.innerHTML).toContain('<svg>mocked diagram</svg>');
    
    expect(mermaid.render).toHaveBeenCalled();
  });

  test('should display error message when mermaid syntax is invalid', async () => {
    const mermaidMock = require('mermaid');
    mermaidMock.render.mockRejectedValueOnce(new Error('Parse error on line 1'));

    const markdown = `
\`\`\`mermaid
invalid syntax here
\`\`\`
    `;

    await window.renderMarkdown(markdown);

    const preview = document.getElementById('markdown-preview');
    const errorDiv = preview?.querySelector('.mermaid-error');
    expect(errorDiv).toBeTruthy();
    expect(errorDiv?.textContent).toContain('Mermaid Syntax Error');
    expect(errorDiv?.textContent).toContain('Parse error on line 1');
  });

  test('should rewrite relative image paths using baseUrl', async () => {
    const markdown = '![img](./pic.png)';
    
    // Execution
    await window.renderMarkdown(markdown, { baseUrl: '/Users/me/docs' });

    // Verification
    const preview = document.getElementById('markdown-preview');
    const img = preview?.querySelector('img');
    expect(img).toBeTruthy();
    // Expect local-resource scheme and clean path
    expect(img?.getAttribute('src')).toBe('local-resource:///Users/me/docs/pic.png');
  });
});
