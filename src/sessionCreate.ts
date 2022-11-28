import {fn, spawnChild} from './factory'

const sessionCreate = fn<{phone: string}, boolean>(
  async args => {
    const userStr = await spawnChild(
      'dotnet',
      'dotnet/bin/Debug/net6.0/Telegram_CLI.dll',
      ['CreateSession', '-p', args.phone]
    )
    return true
  },
  {
    name: 'sessionCreate'
  }
)

export default sessionCreate

// SPDX-License-Identifier: (EUPL-1.2)
// Copyright © 2019-2022 snek.at
