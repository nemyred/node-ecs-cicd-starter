const request = require('supertest');
const app = require('./index');

describe('Sprint Freight CI/CD API', () => {
  it('should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.statusCode).toBe(200);
    expect(response.text).toContain('Hello from Sprint Freight CI/CD!');
  });

  it('should return health check', async () => {
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(200);
    expect(response.text).toBe('OK');
  });
});