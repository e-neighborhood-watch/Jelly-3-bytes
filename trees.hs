import Control.Monad

standardCompose :: Functoid a -> Functoid a -> Functoid a
standardCompose (Functoid comp1 app1 ar1) (Functoid _ app2 ar2) = Functoid standardCompose newApp (ar1 + ar2 -1)
 where newApp l
        | length l == ar1 + ar2 - 1 = app1 $ app2 (drop (ar1 - 1) l) : take (ar1 - 1) l

data ProgTree a = ProgTree (Functoid a) [ProgTree a]

data Functoid a = Functoid {
 composition :: Functoid a -> Functoid a -> Functoid a,
 application :: [a] -> a,
 arity :: Int
}

flatten :: ProgTree a -> Functoid a
flatten (ProgTree f []) = f
flatten (ProgTree f ls) = foldl (join composition) f $ map flatten ls

stitch :: [Functoid a] -> [ProgTree a] -> [ProgTree a]
stitch [] [] = []
stitch (f@(Functoid _ _ ar):xs) ys = ProgTree f (take ar ys) : stitch xs (drop ar ys)

buildTree :: [[Functoid a]] -> ProgTree a
buildTree = head . (foldr stitch []) 

stratify :: Int -> [Functoid a] -> [[Functoid a]]
stratify x fs = layer : stratify (sum $ map arity layer) (drop x fs) 
 where layer = take x fs

