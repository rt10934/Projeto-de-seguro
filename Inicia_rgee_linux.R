# instalando o RGEE:
remotes::install_github("r-spatial/rgee",force = T)
#liberando o pacote:
library(rgee)
ee_install(py_env = 'rgee_env')
# instalando o reticulate:
install.packages("reticulate")
# autentificando e incializando:
ee_Authenticate()
ee_Initialize()
rgee::ee_check()
rgee::ee_check_python()
