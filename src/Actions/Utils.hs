module Actions.Utils (paginateItems) where

import Actions.Types (Pagination (..))
import Database.Item (ItemData)

paginateItems :: [ItemData] -> Int -> Pagination
paginateItems items page =
  Pagination
    { currentPaginationItems = getPaginationItems page items,
      nextPaginationItems = getPaginationItems (page + 1) items,
      previousPaginationItems = if page > 1 then getPaginationItems (page - 1) items else [],
      currentPageCount = page
    }
  where
    itemsInPaginationCount :: Int
    itemsInPaginationCount = 5
    getPaginationItems :: Int -> [ItemData] -> [ItemData]
    getPaginationItems pageCount items = drop (itemsInPaginationCount * (pageCount - 1)) $ take (itemsInPaginationCount * pageCount) items