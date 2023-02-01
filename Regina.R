# declarando diretorio:
setwd("C:/Users/torre/Downloads/dados beatriz")
#Pacotes:
library(tidyr)
library(tidyverse)
library(geobr)
library(ggplot2)
library(ggpubr)
#Importando dados:
library(readxl)
X839 <- read_excel("839.xlsx", col_types = c("numeric","numeric", "text",
                                             "numeric", "text", "numeric",
                                             "numeric", "numeric", "numeric", 
                                             "numeric", "numeric", "numeric"))
X1612 <- read_excel("1612.xlsx", col_types = c("numeric","numeric", "text",
                                             "numeric", "text", "numeric",
                                             "numeric", "numeric", "numeric", 
                                             "numeric", "numeric", "numeric"))
  
X1002 <- read_excel("1002.xlsx", col_types = c("numeric","numeric", "text",
                                             "numeric", "text", "numeric",
                                             "numeric", "numeric", "numeric", 
                                             "numeric", "numeric", "numeric"))
str(X839)
# tabela X839
X839$Nível <- NULL
# tirar mesclagem:
X839 <-X839 |> fill(Cód.)
X839 <-X839 |> fill(Município)
X839 <-X839 |> fill(Ano)

# tabela X839
X1612$Nível <- NULL
# tirar mesclagem:
X1612 <-X1612 |> fill(Cód.)
X1612 <-X1612 |> fill(Município)
X1612 <-X1612 |> fill(Ano)

# tabela X1002
X1002$Nível <- NULL
# tirar mesclagem:
X1002 <-X1002 |> fill(Cód.)
X1002 <-X1002 |> fill(Município)
X1002 <-X1002 |> fill(Ano)
# juntando os dados:
Base<- bind_rows(X839,X1612,X1002)
Base <- rename(Base, "code_muni"=Cód.)
# buscando codigos dos dados por mesoregião
codigo_ibge2 <- read_excel("codigo ibge2.xls", 
                           col_types = c("numeric", "text", "text", 
                                         "numeric", "text", "numeric", "text", 
                                         "text", "text", "text", "text", "text", 
                                         "numeric", "text", "numeric", "text", 
                                         "text", "text"))
codigo<- data.frame("code_muni"=codigo_ibge2$`Código Município Completo`,
                    "code_intermediate"=codigo_ibge2$`Região Geográfica Intermediária`,
                    "nome_inter"=codigo_ibge2$`Nome Região Geográfica Intermediária`)
# juntando os dados com os codigos do ibge:
Base<- full_join(codigo,Base, by="code_muni")
# summatorio:
unique(Base$`Rendimento médio da produção (Quilogramas por Hectare)`)
str(Base)
Base <- Base|> 
  group_by(Ano,cultura,code_intermediate)|>
  summarise("Area_p"=sum(`Área plantada (Hectares)`,na.rm = T),
            "Quantidade_pro"=sum(`Quantidade produzida (Toneladas)`,na.rm = T),
            "rend"=sum(`Rendimento médio da produção (Quilogramas por Hectare)`,na.rm = T))
# buscando shapefile:
cod <- read_intermediate_region(code_intermediate = "all")
# juntando dados ao shapefile:
Base <- full_join(cod,Base,by="code_intermediate")

# filtro:
unique(Base1$cultura)
RA<-"Feijão (em grão) - 1ª safra"
Base1 <- Base

# criando classificação area:
Base1$categoria <- cut((Base1$Area_p/1000),
                       breaks = c(0.0001,10,20,30,60,1000,1000000),
                       labels = c("Até 1","De 10 à 20","De 20 à 30","De 30 à 60",
                                  "De 60 à 1000", "Acima de 1000")) 

# mapas
A00<-Base1|> subset(Ano==2005 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoria),show.legend = T)+
  ggtitle("Ano de 2005")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil Hectares")

A10<-Base1|> subset(Ano==2015 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoria),show.legend = T)+
  ggtitle("Ano de 2015")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil Hectares")

A20<-Base1|> subset(Ano==2020 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoria),show.legend = T)+
  ggtitle("Ano de 2020")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil Hectares")
# juntando os mapas
ggarrange(A00,A10,A20,common.legend = T,legend = 'bottom',ncol = 3,nrow = 1 )

# criando classificação produção
# classificacao 
Base1$categoriaI <- cut((Base1$Quantidade_pro/1000),
                       breaks = c(0.0001,10,20,30,60,1000,1000000),
                       labels = c("Até 1","De 10 à 20","De 20 à 30","De 30 à 60",
                                  "De 60 à 1000", "Acima de 1000")) 
# mapas 
Q00<-Base1|> subset(Ano==2005 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoriaI),show.legend = T)+
  ggtitle("Ano de 2005")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil toneladas")

Q10<-Base1|> subset(Ano==2015 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoriaI),show.legend = T)+
  ggtitle("Ano de 2015")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil toneladas")

Q20<-Base1|> subset(Ano==2020 & cultura==RA)|>
  ggplot()+geom_sf(aes(fill=categoriaI),show.legend = T)+
  ggtitle("Ano de 2020")+
  scale_fill_manual(values = c('#F1F8E9','#C5E1A5','#9CCC65','#7CB342',
                               '#558B2F','#004D40'))+labs(fill="Mil toneladas")
# juntando os mapas
ggarrange(Q00,Q10,Q20,common.legend = T,legend = 'bottom',ncol = 3,nrow = 1 )

ggarrange(Q00,Q10,Q20,A00,A10,A20,common.legend = T,legend = 'bottom',ncol = 3,nrow = 2 )
