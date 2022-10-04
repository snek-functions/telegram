import { fn } from "./factory";

const exampleLogin = fn<{ username: string; password: string }, boolean>(
  async (args) => {
    return args.username === "admin" && args.password === "admin";
  },
  {
    name: "exampleLogin",
  }
);

export default exampleLogin;

// SPDX-License-Identifier: (EUPL-1.2)
// Copyright © 2019-2022 snek.at
