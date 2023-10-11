{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
import           Control.Monad.Trans.Reader
import           UnliftIO
import qualified OpenTelemetry.Trace as Otel
import qualified OpenTelemetry.Trace.Monad as Otel

main :: IO ()
main = bracket
  Otel.initializeGlobalTracerProvider
  Otel.shutdownTracerProvider
  (\tracerProvider -> do
    let tracer = Otel.makeTracer tracerProvider "main" Otel.tracerOptions
    runReaderT (unTest blah) tracer
  )

blah :: Test ()
blah = Test $ pure ()

newtype Test a = Test { unTest :: ReaderT Otel.Tracer IO a }
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadUnliftIO)

instance Otel.MonadTracer Test where
  getTracer = Test ask