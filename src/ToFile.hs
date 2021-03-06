{-| Functions for conversion statistics from the internal representation
    of the program (see Parsing.hs to learn data types) in lines
    for output files.
-}

module ToFile
  ( convert1
  , convert2
  , convert3
  , convert4
  ) where

import Parsing ( Birthday(..), StatsSign, 
                 StatsInfSign, StatsExactSign, StatsBirthday,
               )

import Data.Tuple.Select ( sel1, sel2, sel3 )
import Data.Ord          ( comparing )
import Data.List         ( sortBy, groupBy, )
import Data.Function     ( on )

-- | query1
convert1 :: [StatsSign] -> String
convert1 list = foldr1 (++) $ map toString (sortOn fst list)
  where
    toString tpl = (show . fst) tpl ++ "\t" ++ (show . snd) tpl ++ "\n"

-- | query2
convert2 :: [StatsInfSign] -> String
convert2 list = foldr1 (++) $ map toString
                                  (mvNothingToTheEnd $ sortOn fst list)
  where
    toString :: StatsInfSign -> String
    toString tpl = maybe "Nothing" show (fst tpl) ++ " "
                   ++ (show . snd) tpl ++ "\n"
    mvNothingToTheEnd :: [StatsInfSign] -> [StatsInfSign]
    mvNothingToTheEnd (x:xs) = xs ++ [x]
    mvNothingToTheEnd []     = []

-- | query3
convert3 :: [StatsExactSign] -> String
--convert3 list = foldr1 (++) $ map toString (switch1And2 $ sorting list)
convert3 list = concat $ toString (switch1And2 $ sorting list)
  where
    sorting :: [StatsExactSign] -> [StatsExactSign]
    sorting d = sortOn sel1 (sortOn sel2 d)
    {-
    -- After sort:           Need:
    -- Aries/Nothing 15589   Aries/Taurus 6462
    -- Aries/Taurus 6462     Aries/Nothing 15589
    -- Aries/Pisces 6490     Aries/Pisces 6490
    -}
    switch1And2 :: [StatsExactSign] -> [StatsExactSign]
    switch1And2 (a:b:c:xs) = b:a:c:switch1And2 xs
    switch1And2 []         = []
    switch1And2 [a]        = [a]
    switch1And2 [a, b]     = [a, b]
    toString :: [StatsExactSign] -> [String]
    toString tpl = [v | a:b:c:[] <- groupBy ((==) `on` sel1) tpl,
                        let x = show $ sel1 a,
                        let y = show $ sel3 a,
                        let z = show $ sel3 b,
                        let s = show $ sel3 c,
                        let v = concat [x, " ", y, " ", z," ", s,"\n"]]
{-
    This is version look like
    Aries/Nothing 15589   Aries/Taurus 6462
    Aries/Taurus 6462     Aries/Nothing 15589
    Aries/Pisces 6490

    toString tpl = (show . sel1) tpl ++ "/"
                   ++ maybe "Nothing" show (sel2 tpl)
                     ++ " " ++ (show . sel3) tpl ++ "\n"
-}

-- | query4
convert4 :: [StatsBirthday] -> String
convert4 list = foldr1 (++) $ map toString (sortOn fst list)
  where
    toString :: StatsBirthday -> String
    toString tpl = (show . day . fst) tpl ++ " "
                   ++ (show . month . fst) tpl
                   ++ " " ++ (show . snd) tpl ++ "\n"

-- | Helper functions for sorting before output.
sortOn :: Ord b => (a -> b) -> [a] -> [a]
sortOn f =
  map snd . sortBy (comparing fst) . map (\x -> let y = f x
                                                in y `seq` (y, x))


