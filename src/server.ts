import { createApp } from "./app.js";
import { env } from "./config/env.js";

const app = createApp();

app.listen(env.PORT, () => {
  console.log(`gymtracker-backend listening on :${env.PORT} (${env.NODE_ENV})`);
});
