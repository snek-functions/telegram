import {fn, spawnChild} from './factory'

const messageSend = fn<{username: string; msg: string}, boolean>(
  async args => {
    const userStr = await spawnChild(
      'dotnet',
      'dotnet/bin/Debug/net6.0/Telegram_CLI.dll',
      ['SendMessage', '-u', args.username, '-m', args.msg]
    )
    return true
  },
  {
    name: 'messageSend'
  }
)

export default messageSend

// SPDX-License-Identifier: (EUPL-1.2)
// Copyright © 2019-2022 snek.at
