###############################################################################
############################## Limpieza de datos ##############################
###############################################################################

# Cargamos los paquetes necesarios para realizar el análisis

library(rgdal)
library(RColorBrewer)
library(spdep)

# Cargamos el shapefile con los datos de intoxicaciones y los indicadores por
# canton

s <- readOGR("datos/procesados", "cantones_data", stringsAsFactors=FALSE, encoding="UTF-8")

# Creamos un gráfico de intoxicaciones totales y la tasa de intoxicaciones por
# 10 mil habitantes según el canton y los guardamos en la carpeta `plots`

pdf("plots/Fig1.pdf")

# Cantidad total de intoxicaciones

spplot(s, "intxccn", col.regions = brewer.pal(9, "YlOrRd"), 
       at = seq(0, 740, length.out = 9),
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))

# Cerramos la ventana gráfica

dev.off()

pdf("plots/Fig2.pdf")

# Tasa de intoxicaciones por 10 mil habitantes

spplot(s, "llmd_10", col.regions=brewer.pal(9, "YlOrRd"), 
       at = seq(0, 80, length.out = 9), 
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))

# Cerramos la ventana gráfica

dev.off()

# Ahora, definimos las coordenadas de los cantones y su ID para poder hacer
# algunos gráficos más adelante

coords <- coordinates(s)
IDs <- row.names(s)

# Hacemos un gráfico comparando seis formas distintas de definir cantones
# vecinos y lo guardamos en la carpeta `plots`

pdf("plots/Fig3.pdf")

# Opciones gráficas para eliminar las cajas, poner seis gráficos en una sola
# ventana y eliminar el espacio vacio entre gráficos

par(xaxt = "n", yaxt = "n", tck = 0, mfrow = c(2, 3), mai = c(0, 0, 0, 0), 
    bty = "n")

# Cálculo de vecinos mediante el método de la Reina

s1_nb <- poly2nb(s)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s1_nb, coordinates(s), pch = 19, cex = 0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="a)", cex=2)
box(col = "white")

# Cálculo de vecinos mediante el método de la Torre

s2_nb <- poly2nb(s, queen = F)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s2_nb, coordinates(s), pch = 19, cex = 0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="b)", cex=2)
box(col = "white")

# Cálculo de vecinos mediante kNN con k=1

s8_nb <- knn2nb(knearneigh(coords, k=1), row.names=IDs)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s8_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="c)", cex=2)
box(col = "white")

# Cálculo de vecinos mediante kNN con k=2

s9_nb <- knn2nb(knearneigh(coords, k=2), row.names=IDs)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s9_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="d)", cex=2)
box(col = "white")

# Cálculo de vecinos mediante kNN con k=4

s10_nb <- knn2nb(knearneigh(coords, k=4), row.names=IDs)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s10_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="e)", cex=2)
box(col = "white")

# Cálculo de vecinos mediante kNN con la distancia específicada mediante
# el método de la reina

dsts <- unlist(nbdists(s1_nb, coords))
s12_nb <- dnearneigh(coords, d1=0, d2=0.75*max(dsts), row.names=IDs)

# Graficamos los vecinos sobre el mapa

plot(s, axes=TRUE, border="gray")
plot(s12_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="f)", cex=2)
box(col = "white")

# Cerramos la ventana gráfica

dev.off()

# Calculamos los pesos entre vecinos mediante el estilo S

s1_nb_S <- nb2listw(s1_nb,style = "S")

# Vemos algunas estadisticas descriptivas de los pesos obtenidos

summary(unlist(s1_nb_S$weights))
summary(sapply(s1_nb_S$weights, sum))

# Calculamos datos teóricos sin autocorrelacion espacial

set.seed(987)
n <- length(s1_nb)
uncorr_x <- rnorm(n)
rho <- 0.5
autocorr_x <- invIrW(s1_nb_S, rho) %*% uncorr_x

# Hacemos la prueba I de Moran y los tipos de silla de montar y exacta sobre 
# los residuales del modelo con respecto a las intoxicaciones totales 

lm.morantest(lm(s$intxccn ~ 1, s), listw = s1_nb_S)
lm.morantest.sad(lm(s$intxccn ~ 1, s), listw = s1_nb_S)
lm.morantest.exact(lm(s$intxccn ~ 1, s), listw = s1_nb_S)

# Hacemos la prueba de permutaciones de la I de Moran

set.seed(1234)
bperm <- moran.mc(s$intxccn, listw = s1_nb_S, nsim = 999)
bperm

# Hacemos la prueba EBI de Moran tomando en cuenta la población de los cantones

set.seed(1234)
EBImoran.mc(n = s$intxccn, x = s$poblacn, listw = s1_nb_S, nsim = 999)

# Calculamos la I de Moran y variantes pero para la tasa de intoxicaciones por
# 10 mil habitantes

lm.morantest(lm(s$llmd_10 ~ 1, s), listw = s1_nb_S)
lm.morantest.sad(lm(s$llmd_10 ~ 1, s), listw = s1_nb_S)
lm.morantest.exact(lm(s$llmd_10 ~ 1, s), listw = s1_nb_S)

# Hacemos el gráfico de dispersón de los datos observados y rezagados

oopar <- par(mfrow=c(1,2), oma = c(0, 0, 2, 0))
msp <- moran.plot(s$intxccn, listw=s1_nb_S, quiet=TRUE, xlab = "Intoxicaciones", 
                  ylab = "Intoxicaciones rezagadas espacialmente")

pdf("plots/Fig4.pdf")
infl <- apply(msp$is.inf, 1, any)
x <- s$llmd_10
lhx <- cut(x, breaks=c(min(x), mean(x), max(x)), labels=c("L", "H"), 
           include.lowest=TRUE)
wx <- stats::lag(nb2listw(s1_nb, style="C"), s$llmd_10)
lhwx <- cut(wx, breaks=c(min(wx), mean(wx), max(wx)), labels=c("L", "H"), 
            include.lowest=TRUE)
lhlh <- interaction(lhx, lhwx, infl, drop=TRUE)
cols <- rep(1, length(lhlh))
cols[lhlh == "H.L.TRUE"] <- 2
cols[lhlh == "L.H.TRUE"] <- 3
cols[lhlh == "H.H.TRUE"] <- 4
plot(s, col=brewer.pal(4, "Accent")[cols])
legend("topright", legend = c("Ninguno", "HL", "LH", "HH"), 
       fill = brewer.pal(4, "Accent"), bty = "n", cex = 1.25, y.intersp = 0.8)
dev.off()

# Hacemos el gráfico con los cantones de influencia

lm1 <- localmoran(s$llmd_10, listw = s1_nb_S)
lm2 <- as.data.frame(localmoran.sad(lm(llmd_10 ~ 1, s), nb = s1_nb, 
                                    style = "S"))
lm3 <- as.data.frame(localmoran.exact(lm(llmd_10 ~ 1, s), nb = s1_nb, 
                                      style = "S"))

s$Normal <- lm2[,3]
s$Aleatorizado <- lm1[,5]
s$Punto_de_silla <- lm2[,5]
s$Exacto <- lm3[,5]
gry <- c(rev(brewer.pal(6, "Reds")), brewer.pal(6, "Blues"))

pdf("plots/Fig5.pdf")
spplot(s, c("Normal", "Aleatorizado", "Punto_de_silla", "Exacto"), 
       at=c(0,0.01,0.05,0.1,0.9,0.95,0.99,1), 
       col.regions=colorRampPalette(gry)(7))
dev.off()

# Calculamos el modelo de regresión lineal de la tasa de intoxicaciones por
# 10 mil habitantes, tomando en cuenta las covariables

mod.lm <- lm(llmd_10 ~ por_lfb + por_agr + extnsn_ + trab_gr + menr_15, data = s)
summary(mod.lm)

# Hacemos selección de variables para el modelo

mod.lm <- lm(llmd_10 ~ por_lfb + extnsn_ + trab_gr + menr_15, data = s)
summary(mod.lm)

mod.lm <- lm(llmd_10 ~ por_lfb + extnsn_ + trab_gr, data = s)
summary(mod.lm)

# Hacemos la prueba I de Moran de los residuales

lm.morantest(mod.lm, listw = s1_nb_S)

# Hacemos el modelo SAR con covariables

modsar<-spautolm(llmd_10 ~ por_lfb + por_agr + extnsn_ + trab_gr + menr_15, 
                 data=s, s1_nb_S)
summary(modsar)

# Hacemos selección de variables

modsar<-spautolm(llmd_10 ~ por_lfb + extnsn_ + trab_gr + menr_15, data=s, s1_nb_S)
summary(modsar)

modsar<-spautolm(llmd_10 ~ por_lfb + extnsn_ + trab_gr, data=s, s1_nb_S)
summary(modsar)

# Hacemos la prueba I de Moran sobre los residuales del modelo

moran.mc(residuals(modsar), s1_nb_S, 999)

# Hacemos el modelo CAR

modcar<-spautolm(llmd_10 ~ por_lfb + por_agr + extnsn_ + trab_gr + menr_15, 
                 data=s, s1_nb_S, family = "CAR")
summary(modcar)

# Hacemos seleccion de variables

modcar<-spautolm(llmd_10 ~ por_lfb + extnsn_ + trab_gr + menr_15, data=s, s1_nb_S, 
                 family = "CAR")
summary(modcar)

modcar<-spautolm(llmd_10 ~ por_lfb + extnsn_ + trab_gr, data=s, s1_nb_S, 
                 family = "CAR")
summary(modcar)

# Hacemos la prueba I de Moran para los residuales del modelo CAR

moran.mc(residuals(modcar), s1_nb_S,999)

# Guardamos los residuales para poder graficarlos

s$lmresid <- residuals(mod.lm)
s$sarresid <- residuals(modsar)
s$carresid <- residuals(modcar)

# Graficamos los residuales para los tres modelos sobre el mapa de Costa Rica

pdf("plots/Fig6-1.pdf")
m.lm <- max(abs(s$lmresid), na.rm = TRUE)
spplot(s, "lmresid", at = seq(-m.lm, m.lm ,length = 12), 
       col.regions = rev(brewer.pal(11, "RdBu")), 
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))
text(bbox(s)[1, 1], bbox(s)[2, 2], labels="a)", cex=2)
dev.off()
pdf("plots/Fig6-2.pdf")
m.sar <- max(abs(s$sarresid), na.rm = TRUE)
spplot(s, "sarresid", at = seq(-m.sar, m.sar, length = 12),
       col.regions = rev(brewer.pal(11, "RdBu")), 
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))
dev.off()
pdf("plots/Fig6-3.pdf")
m.car <- max(abs(s$carresid), na.rm = TRUE)
spplot(s, "carresid", at = seq(-m.car, m.car, length = 12),
       col.regions = rev(brewer.pal(11, "RdBu")), 
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))
dev.off()

###############################################################################
##################################### FIN #####################################
###############################################################################