library(rgdal)
library(RColorBrewer)
library(spdep)

# Cargamos los datos
s <- readOGR("datos/procesados", "cantones_data", stringsAsFactors=FALSE, encoding="UTF-8")

# Cantidad de intoxicaciones, totales, por cantón
pdf("plots/Fig1.pdf")
spplot(s, "intxccn", col.regions = brewer.pal(9, "YlOrRd"), 
       at = seq(0, 740, length.out = 9),
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))
dev.off()

# Cantidad de intoxicaciones, por 10 mil habitantes, por cantón
pdf("plots/Fig2.pdf")
spplot(s, "llmd_10", col.regions=brewer.pal(9, "YlOrRd"), 
       at = seq(0, 80, length.out = 9), 
       par.settings = list(axis.line = list(col = "transparent")), 
       colorkey = list(axis.line = list(col = "black")))
dev.off()

# Definición de coordenadas y ID's para hacer mapas
coords <- coordinates(s)
IDs <- row.names(s)

pdf("plots/Fig3.pdf")
par(xaxt = "n", yaxt = "n", tck = 0, mfrow = c(2, 3), mai = c(0, 0, 0, 0), bty = "n")
# Reina
s1_nb <- poly2nb(s)
plot(s, axes=TRUE, border="gray")
plot(s1_nb, coordinates(s), pch = 19, cex = 0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="a)", cex=2)
box(col = "white")
# Torre
s2_nb <- poly2nb(s, queen = F)
plot(s, axes=TRUE, border="gray")
plot(s2_nb, coordinates(s), pch = 19, cex = 0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="b)", cex=2)
box(col = "white")
# kNN 1 vecino
s8_nb <- knn2nb(knearneigh(coords, k=1), row.names=IDs)
plot(s, axes=TRUE, border="gray")
plot(s8_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="c)", cex=2)
box(col = "white")
# kNN 2 vecinos
s9_nb <- knn2nb(knearneigh(coords, k=2), row.names=IDs)
plot(s, axes=TRUE, border="gray")
plot(s9_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="d)", cex=2)
box(col = "white")
# kNN con 4 vecinos
s10_nb <- knn2nb(knearneigh(coords, k=4), row.names=IDs)
plot(s, axes=TRUE, border="gray")
plot(s10_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="e)", cex=2)
box(col = "white")
# kNN con distancia según reinas
dsts <- unlist(nbdists(s1_nb, coords))
s12_nb <- dnearneigh(coords, d1=0, d2=0.75*max(dsts), row.names=IDs)
plot(s, axes=TRUE, border="gray")
plot(s12_nb, coordinates(s), pch=19, cex=0.6, add = T, col = "red")
text(bbox(s)[1,1], bbox(s)[2,2], labels="f)", cex=2)
box(col = "white")
dev.off()

# Reina
s1_nb_W=nb2listw(s1_nb)
s1_nb_W

# Reina
s1_nb_W=nb2listw(s1_nb,style = "W")
summary(unlist(s1_nb_W$weights))
summary(sapply(s1_nb_W$weights, sum))

s1_nb_B=nb2listw(s1_nb,style = "B")
summary(unlist(s1_nb_B$weights))
summary(sapply(s1_nb_B$weights, sum))

s1_nb_S=nb2listw(s1_nb,style = "S")
summary(unlist(s1_nb_S$weights))
summary(sapply(s1_nb_S$weights, sum))

#Reina
pal <- brewer.pal(9, "Reds")
oopar <- par(mfrow=c(1,3), mar=c(1,1,3,1)+0.1, oma = c(0, 0, 2, 0))
z <- t(listw2mat(s1_nb_W))
brks <- c(0,0.1,0.143,0.167,0.2,0.5,1)
nbr3 <- length(brks)-3
image(1:81, 1:81, z[,ncol(z):1], breaks=brks, col=pal[c(1,(9-nbr3):9)],
      main="Estilo W", axes=FALSE)
box()
z <- t(listw2mat(s1_nb_B))
image(1:81, 1:81, z[,ncol(z):1], col=pal[c(1,9)], main="Estilo B", axes=FALSE)
box()
z <- t(listw2mat(s1_nb_S))
image(1:81, 1:81, z[,ncol(z):1], col=pal[c(1,(9-nbr3):9)], main="Estilo S", axes=FALSE)
box()

title("Gráfico 4:\nComparación de distancias entre vecinos según distintos criterios de peso ", outer = TRUE)

par(oopar)

dev.off()

#reina

set.seed(987)
n <- length(s1_nb)
uncorr_x <- rnorm(n)
rho <- 0.5
autocorr_x <- invIrW(s1_nb_S, rho) %*% uncorr_x

lm.morantest(lm(s$intxccn ~ 1, s), listw=s1_nb_S)
lm.morantest.sad(lm(s$intxccn ~ 1, s), listw=s1_nb_S)
lm.morantest.exact(lm(s$intxccn ~ 1, s), listw=s1_nb_S)

set.seed(1234)
bperm <- moran.mc(s$intxccn, listw=s1_nb_S, nsim=999)
bperm

set.seed(1234)
EBImoran.mc(n=s$intxccn, x=s$poblacn, listw=nb2listw(s1_nb, style="S"), nsim=999)

# Llamadas por 10 mil habitantes

lm.morantest(lm(s$llmd_10 ~ 1, s), listw=s1_nb_S)
lm.morantest.sad(lm(s$llmd_10 ~ 1, s), listw=s1_nb_S)
lm.morantest.exact(lm(s$llmd_10 ~ 1, s), listw=s1_nb_S)

oopar <- par(mfrow=c(1,2), oma = c(0, 0, 2, 0))
msp <- moran.plot(s$intxccn, listw=nb2listw(s1_nb, style="C"), quiet=TRUE, xlab = "Intoxicaciones", ylab = "Intoxicaciones rezagadas espacialmente")
infl <- apply(msp$is.inf, 1, any)
x <- s$intxccn
lhx <- cut(x, breaks=c(min(x), mean(x), max(x)), labels=c("L", "H"), include.lowest=TRUE)
wx <- stats::lag(nb2listw(s1_nb, style="C"), s$intxccn)
lhwx <- cut(wx, breaks=c(min(wx), mean(wx), max(wx)), labels=c("L", "H"), include.lowest=TRUE)
lhlh <- interaction(lhx, lhwx, infl, drop=TRUE)
cols <- rep(1, length(lhlh))
cols[lhlh == "H.L.TRUE"] <- 2
cols[lhlh == "L.H.TRUE"] <- 3
cols[lhlh == "H.H.TRUE"] <- 4
plot(s, col=brewer.pal(4, "Accent")[cols])
legend("topright", legend=c("Ninguno", "HL", "LH", "HH"), fill=brewer.pal(4, "Accent"), bty="n", cex=0.8, y.intersp=0.8)
title("Gráfico 5:\nCantones de influencia en casos totales", outer = TRUE)

lm1 <- localmoran(s$intxccn, listw=nb2listw(s1_nb, style="C"))
lm2 <- as.data.frame(localmoran.sad(lm(intxccn ~ 1, s), nb=s1_nb, style="C"))
lm3 <- as.data.frame(localmoran.exact(lm(intxccn ~ 1, s), nb=s1_nb, style="C"))

s$Normal <- lm2[,3]
s$Aleatorizado <- lm1[,5]
s$Punto_de_silla <- lm2[,5]
s$Exacto <- lm3[,5]
gry <- c(rev(brewer.pal(6, "Reds")), brewer.pal(6, "Blues"))
spplot(s, c("Normal", "Aleatorizado", "Punto_de_silla", "Exacto"), at=c(0,0.01,0.05,0.1,0.9,0.95,0.99,1), col.regions=colorRampPalette(gry)(7), main = "Gráfico 6:\nProbabilidad de cada supuesto\n en intoxicaciones totales")

pdf("plots/Fig4.pdf")
oopar <- par(mfrow=c(1,2))
msp <- moran.plot(s$llmd_10, listw=nb2listw(s1_nb, style="C"), quiet=TRUE, xlab = "Intoxicaciones por 10K", ylab = "Intoxicaciones por 10K rezagadas espacialmente")
infl <- apply(msp$is.inf, 1, any)
x <- s$llmd_10
lhx <- cut(x, breaks=c(min(x), mean(x), max(x)), labels=c("L", "H"), include.lowest=TRUE)
wx <- stats::lag(nb2listw(s1_nb, style="C"), s$llmd_10)
lhwx <- cut(wx, breaks=c(min(wx), mean(wx), max(wx)), labels=c("L", "H"), include.lowest=TRUE)
lhlh <- interaction(lhx, lhwx, infl, drop=TRUE)
cols <- rep(1, length(lhlh))
cols[lhlh == "H.L.TRUE"] <- 2
cols[lhlh == "L.H.TRUE"] <- 3
cols[lhlh == "H.H.TRUE"] <- 4
plot(s, col=brewer.pal(4, "Accent")[cols])
legend("topright", legend=c("Ninguno", "HL", "LH", "HH"), fill=brewer.pal(4, "Accent"), bty="n", cex=0.8, y.intersp=0.8)
dev.off()

lm1 <- localmoran(s$llmd_10, listw=nb2listw(s1_nb, style="C"))
lm2 <- as.data.frame(localmoran.sad(lm(llmd_10 ~ 1, s), nb=s1_nb, style="C"))
lm3 <- as.data.frame(localmoran.exact(lm(llmd_10 ~ 1, s), nb=s1_nb, style="C"))

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


# Modelo lineal normal:

mod.lm <- lm(intxccn ~ pr_pb_r + rl_hmb_ + por_lfb + prm_scl + pr_d_rg, data = s, weights = poblacn)
summary(mod.lm)

s$lmresid <- residuals(mod.lm)

spplot(s, c("lmresid"), at=c(seq(-400,500,length.out = 10)), col.regions=colorRampPalette(gry)(10))

lm.morantest(mod.lm, listw=nb2listw(s1_nb, style="S"))


modsar<-spautolm(intxccn ~ pr_pb_r + rl_hmb_ + por_lfb + prm_scl + pr_d_rg, data=s, nb2listw(s1_nb, style="S"), weights = poblacn)
summary(modsar)




# Tasas
mod.lm <- lm(llmd_10 ~ por_lfb + por_agr, data = s)
summary(mod.lm)

s$lmresid <- residuals(mod.lm)

spplot(s, c("lmresid"), at=c(seq(-25,50,length.out = 10)), col.regions=colorRampPalette(gry)(10))

lm.morantest(mod.lm, listw=nb2listw(s1_nb, style="W"))

modsar<-spautolm(llmd_10 ~ por_lfb + por_agr, data=s, nb2listw(s1_nb, style="W"))
summary(modsar)


modcar<-spautolm(llmd_10 ~ por_lfb + por_agr, data=s, nb2listw(s1_nb, style="S"), family = "CAR")
summary(modcar)


lm.LMtests(mod.lm, nb2listw(s1_nb, style="S"), test="all")



errorsalm.chi<-errorsarlm(llmd_10 ~ pr_pb_r + rl_hmb_ + por_lfb + prm_scl + pr_d_rg, data=s, nb2listw(s1_nb, style="S"))
summary(errorsalm.chi)
