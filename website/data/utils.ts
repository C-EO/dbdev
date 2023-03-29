export class NotFoundError extends Error {
  constructor(message?: string) {
    super(message)
    this.name = 'NotFoundError'
  }
}

export class NotImplementedError extends Error {
  constructor(message?: string) {
    super(message)
    this.name = 'NotImplementedError'
  }
}

export class UnknownError extends Error {
  constructor(message?: string) {
    super(message)
    this.name = 'UnknownError'
  }
}

export const DEFAULT_PAGE_SIZE = 20

export function getPagination(page?: number, size: number = DEFAULT_PAGE_SIZE) {
  const limit = size
  const from = page ? page * limit : 0
  const to = page ? from + size - 1 : size - 1

  return { from, to }
}
