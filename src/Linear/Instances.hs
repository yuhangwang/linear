{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ >= 702 && __GLASGOW_HASKELL__ < 710
{-# LANGUAGE Trustworthy #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Copyright   :  (C) 2012-2015 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  portable
--
-- Orphans
-----------------------------------------------------------------------------
module Linear.Instances () where

import Control.Applicative
import Control.Monad.Fix
import Control.Monad.Zip
import Data.Complex
import Data.Functor.Bind
import Data.HashMap.Lazy as HashMap
import Data.Hashable
import Data.Orphans ()
import Data.Semigroup
import Data.Semigroup.Foldable
import Data.Semigroup.Traversable

instance (Hashable k, Eq k) => Apply (HashMap k) where
  (<.>) = HashMap.intersectionWith id

instance (Hashable k, Eq k) => Bind (HashMap k) where
  -- this is needlessly painful
  m >>- f = HashMap.fromList $ do
    (k, a) <- HashMap.toList m
    case HashMap.lookup k (f a) of
      Just b -> [(k,b)]
      Nothing -> []

instance Apply Complex where
  (a :+ b) <.> (c :+ d) = a c :+ b d

instance Bind Complex where
  (a :+ b) >>- f = a' :+ b' where
    a' :+ _  = f a
    _  :+ b' = f b
  {-# INLINE (>>-) #-}

instance MonadZip Complex where
  mzipWith = liftA2

instance MonadFix Complex where
  mfix f = (let a :+ _ = f a in a) :+ (let _ :+ a = f a in a)

instance Foldable1 Complex where
  foldMap1 f (a :+ b) = f a <> f b
  {-# INLINE foldMap1 #-}

instance Traversable1 Complex where
  traverse1 f (a :+ b) = (:+) <$> f a <.> f b
  {-# INLINE traverse1 #-}
