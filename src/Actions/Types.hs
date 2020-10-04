module Actions.Types
  ( Pagination(..)
  )
where

import           Database.Item                  ( ItemData )

data Pagination = Pagination
  { previousPaginationItems :: [ItemData],
    currentPaginationItems :: [ItemData],
    nextPaginationItems :: [ItemData],
    currentPageCount :: Int
  }
