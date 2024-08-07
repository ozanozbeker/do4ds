# Load Packages
library(pins)
library(plumber)
library(rapidoc)
library(vetiver)
library(log4r)
library(paws)
library(glmnet)                                                                                                   
library(parsnip)                                                                                                  
library(recipes)                                                                                                
library(workflows)

# Initialize logger
logger = logger(appenders = file_appender("logs/plumber.log"))

# Log the start of the API
info(logger, "Starting API...")

b = board_s3("do4ds")
v = vetiver_pin_read(b, "penguin_lm")

# Log model loading
info(logger, "Model loaded successfully.")

#* @plumber
function(pr) {
  pr |> 
    # Log each incoming request
    pr_hook("preroute", function(req) {
      info(logger, paste("Incoming request:", req$REQUEST_METHOD, req$PATH_INFO))
    }) |> 
    # Log response status
    pr_hook("postroute", function(res) {
      info(logger, paste("Response status:", res$status))
    }) |> 
    vetiver_api(v)
}
