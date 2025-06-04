/* Creamos la tabla con los ejemplares a actualizar */

DROP TABLE IF EXISTS snibdtap.po_ejemplarregionsitiosig;
DROP TABLE IF EXISTS snibdtap.po_ejemplarregionconteo;
DROP TABLE IF EXISTS snibdtap.po_ejemplarregionconteonew;
DROP TABLE IF EXISTS snibdtap.po_conteosnuevosregionsitiosig;
DROP TABLE IF EXISTS snibdtap.po_conteosnuevosregionsitiosig_previa;

-- La tabla snibdtap.po_Manglar_validado_entrega cambia por la qnueva tabla que tenga los ejemplares a modificar
create table snibdtap.po_ejemplarregionsitiosig
SELECT e.llaveejemplar,r.* FROM snibdtap.si_ousp_4750 p inner join snib.ejemplar_curatorial e on p.llaveejemplar=e.llaveejemplar
inner join snib.conabiogeografia r on e.llaveregionsitiosig=r.llaveregionsitiosig;

ALTER TABLE `snibdtap`.`po_ejemplarregionsitiosig` ADD COLUMN `llaveregionsitiosig_new` VARCHAR(32) AFTER `fechaactualizacion`,
ADD INDEX `Index_1`(`llaveejemplar`);
 
 /*Actualizamos los campos necesarios, esta consulta cambia cada que se requiere un cambio, porque siempre son campos
 diferentes los que se actualizan, ojo con los siguientes campos
 iddatumuniformizado
 idobservaciondatumuniformizado
 idobservacionescoordenadasconabio
idprocesovalidacion
 idregionmapa
 idrasgogeograficomapa
 idregionmarinamapa
 idmt24mapa
 idzonamapa
   idregionhistorico
 idfuentegeorreferenciacion
 idobservacionesgeorreferenciacion
 idanpinternacional
 idanpfederales
 idanpestatales
 idanpotras
 idfechavalidaciongeografica
 idvegetacionserenanalcms
 
 Son campos que se deben de llenar antes de continuar con el proceso*/



/* En esta ocación solo cambiaron los campos procesovalidacion, zonamapa, regionmarinamapa y paismapa, es necesario actualizar cada una de las llaves */

ALTER TABLE snibdtap.si_ousp_4750
ADD COLUMN idprocesovalidacion tinyint unsigned,
ADD COLUMN idregionmarinamapa tinyint unsigned,
ADD COLUMN idzonamapa tinyint unsigned,
ADD COLUMN  `idregionmapa` smallint(5) unsigned,
ADD COLUMN  `continentemapa` varchar(50) NOT NULL DEFAULT '',
ADD COLUMN  `clavepaismapa` varchar(2) NOT NULL DEFAULT '',
ADD COLUMN  `idestadomapa` mediumint(8) unsigned DEFAULT NULL ,
ADD COLUMN  `claveestadomapa` varchar(10) NOT NULL DEFAULT '',
ADD COLUMN  `nombreestadomapa` varchar(50) NOT NULL DEFAULT '',
ADD COLUMN  `idmunicipiomapa` int(10) unsigned DEFAULT NULL,
ADD COLUMN  `clavemunicipiomapa` varchar(10) NOT NULL DEFAULT '',
ADD COLUMN  `nombremunicipiomapa` varchar(80) NOT NULL DEFAULT '',
ADD COLUMN  `claveniveladministrativoadicionalmapa` varchar(20) NOT NULL DEFAULT '',
ADD COLUMN  `nombreniveladministrativoadicionalmapa` varchar(50) NOT NULL DEFAULT '',
ADD COLUMN  `llaveregionmapa` varchar(32) NOT NULL DEFAULT '';


update snibdtap.si_ousp_4750 g inner join snib.procesovalidacion d on g.procesovalidacion=d.procesovalidacion
set g.idprocesovalidacion=d.idprocesovalidacion;

insert into snib.procesovalidacion(procesovalidacion)
select distinct procesovalidacion from snibdtap.si_ousp_4750
where idprocesovalidacion is null;

update snibdtap.si_ousp_4750 s inner join snib.procesovalidacion r on s.procesovalidacion=r.procesovalidacion
set g.idprocesovalidacion=d.idprocesovalidacion
where procesovalidacion is null;



-- Ene sta ocación para la tabla regionmapa solo cambio el campo paismapa, por lo que extraemos los valores de los demas campos antes de actualizar la llaveregionmapa

update snibdtap.si_ousp_4750 g inner join snib.ejemplar_curatorial e on g.llaveejemplar=e.llaveejemplar
inner join snib.conabiogeografia r on e.llaveregionsitiosig=r.llaveregionsitiosig
inner join snib.regionmapa rm on r.idregionmapa=rm.idregionmapa
set g.continentemapa=rm.continentemapa,
g.clavepaismapa=rm.clavepaismapa,
g.idestadomapa=rm.idestadomapa,
g.claveestadomapa=rm.claveestadomapa,
g.nombreestadomapa=rm.nombreestadomapa,
g.idmunicipiomapa=rm.idmunicipiomapa,
g.clavemunicipiomapa=rm.clavemunicipiomapa,
g.nombremunicipiomapa=rm.nombremunicipiomapa,
g.claveniveladministrativoadicionalmapa=rm.claveniveladministrativoadicionalmapa,
g.nombreniveladministrativoadicionalmapa=rm.nombreniveladministrativoadicionalmapa;

update snibdtap.si_ousp_4750
set llaveregionmapa=MD5(CONCAT(if(continentemapa='','n',continentemapa),
if(clavepaismapa='','n',clavepaismapa),
if(paismapa='','n',paismapa),
ifnull(idestadomapa,'n'),
if(claveestadomapa='','n',claveestadomapa),
if(nombreestadomapa='','n',nombreestadomapa),
ifnull(idmunicipiomapa,'n'),
if(clavemunicipiomapa='','n',clavemunicipiomapa),
if(nombremunicipiomapa='','n',nombremunicipiomapa),
if(claveniveladministrativoadicionalmapa='','n',claveniveladministrativoadicionalmapa),
if(nombreniveladministrativoadicionalmapa='','n',nombreniveladministrativoadicionalmapa)));

update snibdtap.si_ousp_4750 s inner join snib.regionmapa r on s.llaveregionmapa=r.llaveregionmapa
set s.idregionmapa=r.idregionmapa;

insert into snib.regionmapa(continentemapa,clavepaismapa,nombrepaismapa,idestadomapa,claveestadomapa,nombreestadomapa,idmunicipiomapa,clavemunicipiomapa,nombremunicipiomapa,claveniveladministrativoadicionalmapa,nombreniveladministrativoadicionalmapa,llaveregionmapa)
SELECT distinct continentemapa,clavepaismapa,paismapa,idestadomapa,claveestadomapa,nombreestadomapa,idmunicipiomapa,clavemunicipiomapa,nombremunicipiomapa,claveniveladministrativoadicionalmapa,nombreniveladministrativoadicionalmapa,llaveregionmapa
FROM snibdtap.si_ousp_4750
where idregionmapa is null;

update snibdtap.si_ousp_4750 s inner join snib.regionmapa r on s.llaveregionmapa=r.llaveregionmapa
set s.idregionmapa=r.idregionmapa
where s.idregionmapa is null;

/* update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.rasgogeograficomapa r on g.nombrerasgogeograficomapa=r.nombrerasgogeograficomapa and g.tiporasgogeograficomapa=r.tiporasgogeograficomapa
set g.idrasgogeograficomapa=r.idrasgograficomapa

insert into snib.rasgogeograficomapa(nombrerasgogeograficomapa,tiporasgogeograficomapa)
select distinct nombrerasgogeograficomapa,tiporasgogeograficomapa from snibdtap.0SF_actualizarvalidacionENTREGA
where idrasgogeograficomapa is null; */


update snibdtap.si_ousp_4750 s inner join snib.regionmarinamapa r on s.regionmarinamapa=r.regionmarinamapa
set s.idregionmarinamapa=r.idregionmarinamapa;

insert into snib.regionmarinamapa(regionmarinamapa)
select distinct regionmarinamapa from snibdtap.si_ousp_4750
where idregionmarinamapa is null;

update snibdtap.si_ousp_4750 s inner join snib.regionmarinamapa r on s.regionmarinamapa=r.regionmarinamapa
set s.idregionmarinamapa=r.idregionmarinamapa
where idregionmarinamapa is null;


/*update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.mt24mapa m on g.mt24mapa=m.mt24mapa
and g.mt24idestadomapa=m.mt24idestadomapa
and g.mt24claveestadomapa=m.mt24claveestadomapa
and g.mt24nombreestadomapa=m.mt24nombreestadomapa
and g.mt24idmunicipiomapa=m.mt24idmunicipiomapa
and g.mt24clavemunicipiomapa=m.mt24clavemunicipiomapa
and g.mt24nombremunicipiomapa=m.mt24nombremunicipiomapa
and g.mt24claveniveladministrativoadicionalmapa=m.mt24claveniveladministrativoadicionalmapa
and g.mt24nombreniveladministrativoadicionalmapa=m.mt24nombreniveladministrativoadicionalmapa
set g.idmt24mapa=m.idmt24mapa;

insert into snib.mt24mapa(mt24mapa,mt24idestadomapa,mt24claveestadomapa,mt24nombreestadomapa,mt24idmunicipiomapa,mt24clavemunicipiomapa,mt24nombremunicipiomapa,mt24claveniveladministrativoadicionalmapa,mt24nombreniveladministrativoadicionalmapa)
select distinct mt24mapa,mt24idestadomapa,mt24claveestadomapa,mt24nombreestadomapa,mt24idmunicipiomapa,mt24clavemunicipiomapa,mt24nombremunicipiomapa,mt24claveniveladministrativoadicional,mt24nombreniveladministrativoadicionalmapa
from snibdtap.0SF_actualizarvalidacionENTREGA
where idmt24mapa is null; */


update snibdtap.si_ousp_4750 s inner join snib.zonamapa r on s.zonamapa=r.zonamapa
set s.idzonamapa=r.idzonamapa;

insert into snib.zonamapa(zonamapa)
select distinct zonamapa from snibdtap.si_ousp_4750
where idzonamapa is null;

update snibdtap.si_ousp_4750 s inner join snib.zonamapa r on s.zonamapa=r.zonamapa
set s.idzonamapa=r.idzonamapa
where idzonamapa is null;

/*update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.regionhistorico r on g.claveestadohistorico=r.claveestadohistorico
and g.nombreestadohistorico=r.nombreestadohistorico
and g.clavemunicipiohistorico=r.clavemunicipiohistorico
and g.nombremunicipiohistorico=r.nombremunicipiohistorico
set g.idregionhistorico=r.idregionhistorico;

update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.fuentegeorreferenciacion d on g.fuentegeorreferenciacion=d.fuentegeorreferenciacion
set g.idfuentegeorreferenciacion=d.idfuentegeorreferenciacion;

insert into snib.fuentegeorreferenciacion(fuentegeorreferenciacion)
select distinct fuentegeorreferenciacion from snibdtap.GeozeaperennisENTREGAgeorreferenciados
where idfuentegeorreferenciacion is null;

update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.observacionesgeorreferenciacion d on g.observacionesgeorreferenciacion=d.observacionesgeorreferenciacion
set g.idobservacionesgeorreferenciacion=d.idobservacionesgeorreferenciacion;

insert into snib.observacionesgeorreferenciacion(observacionesgeorreferenciacion)
select distinct observacionesgeorreferenciacion from snibdtap.GeozeaperennisENTREGAgeorreferenciados
where idobservacionesgeorreferenciacion is null;

update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.fechavalidaciongeografica d on g.fechavalidaciongeografica=d.fechavalidaciongeografica
set g.idfechavalidaciongeografica=d.idfechavalidaciongeografica;

insert into snib.fechavalidaciongeografica(fechavalidaciongeografica)
select distinct fechavalidaciongeografica from snibdtap.0SF_actualizarvalidacionENTREGA
where idfechavalidaciongeografica is null;

update snibdtap.GeozeaperennisENTREGAgeorreferenciados g inner join snib.vegetacionserenanalcms d on g.vegetacionserenanalcms=d.vegetacionserenanalcms
set g.idvegetacionserenanalcms=d.idvegetacionserenanalcms; */


 
/* update  update  snibdtap.po_ejemplarregionsitiosig p inner join snibdtap.si_ousp_4750  m on p.llaveejemplar=m.llaveejemplar
set
p.validacionpais=m.validacionpais,
p.validacionestado=m.validacionestado,
p.validacionmunicipio=m.validacionmunicipio,
p.validacionniveladministrativoadicional=m.validacionniveladministrativoadicional,
p.validacionlocalidad=m.validacionlocalidad,
p.zeemt=m.zeemt,
p.codificacion=m.codificacion,
p.idprocesovalidacion=m.idprocesovalidacion,
p.idregionmapa=m.idregionmapa,
p.idrasgogeograficomapa=m.idrasgogeograficomapa,
p.idregionmarinamapa=m.idregionmarinamapa,
p.idmt24mapa=m.idmt24mapa,
p.idzonamapa=m.idzonamapa,
p.idvegetacionprimariainegi=m.idvegetacionprimariainegi,
p.altitudmapa=m.altitudmapa,
p.idregionhistorico=m.idregionhistorico,
p.paiscodigovalidacion=m.paiscodigovalidacion,
p.estadocodigovalidacion=m.estadocodigovalidacion,
p.municipiocodigovalidacion=m.municipiocodigovalidacion,
p.niveladministrativoadicionalcodigovalidacion=m.niveladministrativoadicionalcodigovalidacion,
p.localidadcodigovalidacion=m.localidadcodigovalidacion,
p.validacionmodelo=m.validacionmodelo,
p.modeloscodigovalidacion=m.modeloscodigovalidacion,
p.idfechavalidaciongeografica=m.idfechavalidaciongeografica,
p.usvsIcodigo=m.usvsIcodigo,
p.usvsIIcodigo=m.usvsIIcodigo,
p.usvsIIIcodigo=m.usvsIIIcodigo,
p.usvsIVcodigo=m.usvsIVcodigo,
p.usvsVcodigorestringido=m.usvsVcodigorestringido,
p.usvsVIcodigo=m.usvsVIcodigo,
p.usvsV=m.usvsV,
p.usvsVI=m.usvsVI,
p.idvegetacionserenanalcms=m.idvegetacionserenanalcms,
p.distmpio=m.distmpio;

UPDATE snibdtap.po_ejemplarregionsitiosig p inner join snib.regionmapa r on p.idregionmapa=r.idregionmapa
SET idmias = MD5(
CONCAT(
ifnull(latitudconabio,0),
ifnull(longitudconabio,0),
ifnull(nombrepaismapa,''),
ifnull(nombreestadomapa,''),
ifnull(nombremunicipiomapa,'')
)
); */

-- En esta ocación como cambio paismapa si cambia el campo idMIAS

update snibdtap.po_ejemplarregionsitiosig p inner join snibdtap.si_ousp_4750  m on p.llaveejemplar=m.llaveejemplar
SET p.idmias = MD5(
CONCAT(
ifnull(p.latitudconabio,0),
ifnull(p.longitudconabio,0),
ifnull(m.paismapa,''),
ifnull(m.nombreestadomapa,''),
ifnull(m.nombremunicipiomapa,'')
)
);



update snibdtap.po_ejemplarregionsitiosig p inner join snibdtap.si_ousp_4750  m on p.llaveejemplar=m.llaveejemplar
set
p.idprocesovalidacion=m.idprocesovalidacion,
p.idregionmapa=m.idregionmapa,
p.idregionmarinamapa=m.idregionmarinamapa,
p.idzonamapa=m.idzonamapa;

-



update snibdtap.po_ejemplarregionsitiosig
set llaveregionsitiosig_new =MD5(concat(
ifnull(longitud,'n'),
ifnull(latitud,'n'),
ifnull(longituduniformizada,'n'),
ifnull(latituduniformizada,'n'),
ifnull(iddatumuniformizado,'n'),
ifnull(idobservaciondatumuniformizado,'n'),
origendatumuniformizado,
ifnull(longitudconabio,'n'),
ifnull(latitudconabio,'n'),
datumconabio,
ifnull(incertidumbreconabio,'n'),
ifnull(idobservacionescoordenadasconabio,'n'),
validacionpais,
validacionestado,
validacionmunicipio,
validacionniveladministrativoadicional,
validacionlocalidad,
zeemt,
ifnull(codificacion,'n'),
ifnull(idprocesovalidacion,'n'),
ifnull(idregionmapa,'n'),
ifnull(idrasgogeograficomapa,'n'),
ifnull(idregionmarinamapa,'n'),
ifnull(idmt24mapa,'n'),
ifnull(idzonamapa,'n'),
ifnull(idvegetacionprimariainegi,'n'),
ifnull(altitudmapa,'n'),
ifnull(idregionhistorico,'n'),
ifnull(idfuentegeorreferenciacion,'n'),
ifnull(idobservacionesgeorreferenciacion,'n'),
idmias,
ifnull(paiscodigovalidacion,'n'),
ifnull(estadocodigovalidacion,'n'),
ifnull(municipiocodigovalidacion,'n'),
ifnull(niveladministrativoadicionalcodigovalidacion,'n'),
ifnull(localidadcodigovalidacion,'n'),
validacionmodelo,
ifnull(modeloscodigovalidacion,'n'),
ifnull(usvsIcodigo,'n'),
ifnull(usvsIIcodigo,'n'),
ifnull(usvsIIIcodigo,'n'),
ifnull(usvsIVcodigo,'n'),
ifnull(usvsVcodigorestringido,'n'),
ifnull(usvsVIcodigo,'n'),
ifnull(usvsVIIcodigo,'n'),
usvsV,
usvsVI,
usvsVII,
ifnull(idvegetacionserenanalcms,'n'),
ifnull(distmpio,'n'),version));

/*Verificar que lo que vamos a agregar no existe enla tabla regionsitiosig*/

select  count(1) from snibdtap.po_ejemplarregionsitiosig p inner join snib.conabiogeografia r
on p.llaveregionsitiosig_new=r.llaveregionsitiosig;


ALTER TABLE snibdtap.po_ejemplarregionsitiosig add column yaexistellave varchar(2);

update snibdtap.po_ejemplarregionsitiosig p inner join snib.conabiogeografia r on p.llaveregionsitiosig_new=r.llaveregionsitiosig
set p.yaexistellave='SI';


/* Agregamos los nuevos registros de regionsitiosig, ojo con el valor de ultimafechaactualizacion, igual y se
tiene que ingresar el dato a mano en el qry. */

insert into snib.conabiogeografia(
llaveregionsitiosig,longitud,latitud,longituduniformizada,latituduniformizada,iddatumuniformizado,idobservaciondatumuniformizado,origendatumuniformizado,
longitudconabio,latitudconabio,datumconabio,incertidumbreconabio,idobservacionescoordenadasconabio,validacionpais,validacionestado,validacionmunicipio,
validacionniveladministrativoadicional,validacionlocalidad,zeemt,codificacion,idprocesovalidacion,idregionmapa,idrasgogeograficomapa,idregionmarinamapa,
idmt24mapa,idzonamapa,idvegetacionprimariainegi,altitudmapa,idregionhistorico,idfuentegeorreferenciacion,idobservacionesgeorreferenciacion,idmias,
paiscodigovalidacion,estadocodigovalidacion,municipiocodigovalidacion,niveladministrativoadicionalcodigovalidacion,localidadcodigovalidacion,
validacionmodelo,modeloscodigovalidacion,idfechavalidaciongeografica,usvsIcodigo,usvsIIcodigo,usvsIIIcodigo,usvsIVcodigo,usvsVcodigorestringido,
usvsVIcodigo,usvsVIIcodigo,usvsV,usvsVI,usvsVII,idvegetacionserenanalcms,distmpio,ultimafechaactualizacion,version)
(select llaveregionsitiosig_new,longitud,latitud,longituduniformizada,latituduniformizada,iddatumuniformizado,idobservaciondatumuniformizado,origendatumuniformizado,
longitudconabio,latitudconabio,datumconabio,incertidumbreconabio,idobservacionescoordenadasconabio,validacionpais,validacionestado,validacionmunicipio,
validacionniveladministrativoadicional,validacionlocalidad,zeemt,codificacion,idprocesovalidacion,idregionmapa,idrasgogeograficomapa,idregionmarinamapa,
idmt24mapa,idzonamapa,idvegetacionprimariainegi,altitudmapa,idregionhistorico,idfuentegeorreferenciacion,
idobservacionesgeorreferenciacion,idmias,paiscodigovalidacion,estadocodigovalidacion,municipiocodigovalidacion,niveladministrativoadicionalcodigovalidacion,
localidadcodigovalidacion,validacionmodelo,
modeloscodigovalidacion,max(idfechavalidaciongeografica),usvsIcodigo,usvsIIcodigo,usvsIIIcodigo,usvsIVcodigo,usvsVcodigorestringido,usvsVIcodigo,usvsVIIcodigo,usvsV,
usvsVI,usvsVII,idvegetacionserenanalcms,distmpio,max(ultimafechaactualizacion),version
from snibdtap.po_ejemplarregionsitiosig where yaexistellave is null
group by llaveregionsitiosig_new);

/* ojo con este update, en esta ocaciòn como no hubo cambios en latitudconabio y longitudconabio se puede actualizar directo. */
update snib.relanpconabiogeografia r inner join snibdtap.po_ejemplarregionsitiosig p on p.llaveregionsitiosig=r.llaveregionsitiosig
set r.llaveregionsitiosig=p.llaveregionsitiosig_new;

-- Agregado el 2024-10-04
-- Con el anterior update se pueden repetir tuplas llaveregionsitiosig,idanp,distancia.  Procedemos a eliminarlas


select llaveregionsitiosig,idanp,distancia,count(1)
from snib.relanpconabiogeografia
group by 1,2,3
having count(1)>1;

-- si el anterior qry trae resultados hacemos lo siguiente

drop table if exists snibdtap.tuplasregionsitiosig;

create table snibdtap.tuplasregionsitiosig
select max(idrelanpconabiogeografia) as idrelanpconabiogeografia,llaveregionsitiosig,idanp,distancia,count(1)
from snib.relanpconabiogeografia
group by 2,3,4
having count(1)>1;

-- con este qry eliminamos los duplicados en repeticiones de dos tuplas, cuando haya 3 se repite el proceso de genrar la tabla con el max(idrelanpconabiogeografia)

delete r.* from snibdtap.tuplasregionsitiosig t inner join snib.relanpconabiogeografia r using(idrelanpconabiogeografia);

update snib.ejemplar_curatorial e inner join snibdtap.po_ejemplarregionsitiosig p on p.llaveejemplar=e.llaveejemplar
set e.llaveregionsitiosig=p.llaveregionsitiosig_new;

delete c.* from snib.conabiogeografia c left join snib.ejemplar_curatorial e on c.llaveregionsitiosig=e.llaveregionsitiosig
where e.llaveregionsitiosig is null;

/* Hasta aqui termina el procedimiento, lo siguiente es para tomarlo de referencia cuando se quiera actualizar e ingresar algun catalogo de la tabla conabiogeografia */


alter table snibdtap.po_ejemplarregionsitiosig
ADD COLUMN `iddatumuniformizado` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único del datum uniformizado',
  ADD COLUMN `idobservaciondatumuniformizado` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único de las observaciones al datumuniformizado',
ADD COLUMN   `idobservacionescoordenadasconabio` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único de las observaciones a las coordenadasconabio',
  ADD COLUMN `idprocesovalidacion` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único delprocesevalidacion',
  ADD COLUMN `idregionmapa` smallint(5) unsigned NOT NULL COMMENT 'Identificador único del agrupado de región mapa',
  ADD COLUMN `idrasgogeograficomapa` smallint(5) unsigned NOT NULL COMMENT 'Identificador único del agrupado de rasgogeograficomapa',
  ADD COLUMN `idregionmarinamapa` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único de la regionmarinamapa',
  ADD COLUMN `idmt24mapa` smallint(5) unsigned NOT NULL COMMENT 'Identificador único del agrupado de mt24maoa',
  ADD COLUMN `idzonamapa` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único de la zonamapa',
  ADD COLUMN `idvegetacionprimariainegi` tinyint(3) unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `idregionhistorico` smallint(5) unsigned NOT NULL COMMENT 'Identificador único del agrupado de regionhistorico',
  ADD COLUMN `idfuentegeorreferenciacion` smallint(5) unsigned NOT NULL COMMENT 'Identificador único de las fuentes de georreferenciacion',
  ADD COLUMN `idobservacionesgeorreferenciacion` smallint(5) unsigned NOT NULL COMMENT 'Identificador único de la observación de la georreferenciacion',
  ADD COLUMN `idfechavalidaciongeografica` tinyint(3) unsigned NOT NULL COMMENT 'Identificador único de fecha validación geográfica',
  ADD COLUMN `idvegetacionserenanalcms` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Identificador único de la vegetación para paises diferentes a México de snib sin fronteras',
  add column llaveregionmarinamapa varchar(32) NOT NULL DEFAULT '',
  add column llaveregionmapa varchar(32) NOT NULL DEFAULT '',
  add column llavemt24mapa varchar(32) NOT NULL DEFAULT '',
  add column llaveregionhistorico varchar(32) NOT NULL DEFAULT '';


CALL snib.18_NullAVacioyTrimTabla('snibdtap','po_ejemplarregionsitiosig');

update snibdtap.po_ejemplarregionsitiosig p inner join snib.rasgogeograficomapa r on p.nombrerasgogeograficomapa=r.nombrerasgogeograficomapa and p.tiporasgogeograficomapa=r.tiporasgogeograficomapa
set p.idrasgogeograficomapa=r.idrasgogeograficomapa;

insert into snib.rasgogeograficomapa(nombrerasgogeograficomapa,tiporasgogeograficomapa)
select distinct nombrerasgogeograficomapa,tiporasgogeograficomapa
from po_ejemplarregionsitiosig
where idrasgogeograficomapa=0;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.vegetacionserenanalcms d using(vegetacionserenanalcms)
set e.idvegetacionserenanalcms=d.idvegetacionserenanalcms;

insert into snib.vegetacionserenanalcms(vegetacionserenanalcms);
select distinct vegetacionserenanalcms from snibdtap.po_ejemplarregionsitiosig
where idvegetacionserenanalcms=0 and vegetacionserenanalcms<>'';

update snibdtap.po_ejemplarregionsitiosig e inner join snib.fechavalidaciongeografica d using(fechavalidaciongeografica)
set e.idfechavalidaciongeografica=d.idfechavalidaciongeografica;

insert into snib.fechavalidaciongeografica(fechavalidaciongeografica)
select distinct fechavalidaciongeografica from snibdtap.po_ejemplarregionsitiosig
where idfechavalidaciongeografica=0 or idfechavalidaciongeografica is null;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.observacionesgeorreferenciacion d using(observacionesgeorreferenciacion)
set e.idobservacionesgeorreferenciacion=d.idobservacionesgeorreferenciacion;


update snibdtap.po_ejemplarregionsitiosig e inner join snib.fuentegeorreferenciacion d using(fuentegeorreferenciacion)
set e.idfuentegeorreferenciacion=d.idfuentegeorreferenciacion;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.zonamapa d using(zonamapa)
set e.idzonamapa=d.idzonamapa;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.regionmarinamapa d using(regionmarinamapa)
set e.idregionmarinamapa=d.idregionmarinamapa;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.procesovalidacion d using(procesovalidacion)
set e.idprocesovalidacion=d.idprocesovalidacion;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.observacionescoordenadasconabio d using(observacionescoordenadasconabio)
set e.idobservacionescoordenadasconabio=d.idobservacionescoordenadasconabio;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.observaciondatumuniformizado d using(observaciondatumuniformizado)
set e.idobservaciondatumuniformizado=d.idobservaciondatumuniformizado;

update snibdtap.po_ejemplarregionsitiosig e inner join snib.datumuniformizado d using(datumuniformizado)
set e.iddatumuniformizado=d.iddatumuniformizado;

update snibdtap.po_ejemplarregionsitiosig
set llaveregionmapa=MD5(CONCAT(if(continentemapa='','n',continentemapa),
if(clavepaismapa='','n',clavepaismapa),
if(nombrepaismapa='','n',nombrepaismapa),
ifnull(idestadomapa,'n'),
if(claveestadomapa='','n',claveestadomapa),
if(nombreestadomapa='','n',nombreestadomapa),
ifnull(idmunicipiomapa,'n'),
if(clavemunicipiomapa='','n',clavemunicipiomapa),
if(nombremunicipiomapa='','n',nombremunicipiomapa),
if(claveniveladministrativoadicionalmapa='','n',claveniveladministrativoadicionalmapa),
if(nombreniveladministrativoadicionalmapa='','n',nombreniveladministrativoadicionalmapa)));

update snibdtap.po_ejemplarregionsitiosig
set llaveregionhistorico=MD5(CONCAT(if(claveestadohistorico='','n',claveestadohistorico),
if(nombreestadohistorico='','n',nombreestadohistorico),
if(clavemunicipiohistorico='','n',clavemunicipiohistorico),
if(nombremunicipiohistorico='','n',nombremunicipiohistorico)));

update snibdtap.po_ejemplarregionsitiosig
set llavemt24mapa=MD5(CONCAT(if(mt24mapa='','n',mt24mapa),
ifnull(mt24idestadomapa,'n'),
if(mt24claveestadomapa='','n',mt24claveestadomapa),
if(mt24nombreestadomapa='','n',mt24nombreestadomapa),
ifnull(mt24idmunicipiomapa,'n'),
if(mt24clavemunicipiomapa='','n',mt24clavemunicipiomapa),
if(mt24nombremunicipiomapa='','n',mt24nombremunicipiomapa),
if(mt24claveniveladministrativoadicionalmapa='','n',mt24claveniveladministrativoadicionalmapa),
if(mt24nombreniveladministrativoadicionalmapa='','n',mt24nombreniveladministrativoadicionalmapa)));

update snib.regionmapa
set llaveregionmapa=MD5(CONCAT(if(continentemapa='','n',continentemapa),
if(clavepaismapa='','n',clavepaismapa),
if(nombrepaismapa='','n',nombrepaismapa),
ifnull(idestadomapa,'n'),
if(claveestadomapa='','n',claveestadomapa),
if(nombreestadomapa='','n',nombreestadomapa),
ifnull(idmunicipiomapa,'n'),
if(clavemunicipiomapa='','n',clavemunicipiomapa),
if(nombremunicipiomapa='','n',nombremunicipiomapa),
if(claveniveladministrativoadicionalmapa='','n',claveniveladministrativoadicionalmapa),
if(nombreniveladministrativoadicionalmapa='','n',nombreniveladministrativoadicionalmapa)));

update snib.mt24mapa
set llavemt24mapa=MD5(CONCAT(if(mt24mapa='','n',mt24mapa),
ifnull(mt24idestadomapa,'n'),
if(mt24claveestadomapa='','n',mt24claveestadomapa),
if(mt24nombreestadomapa='','n',mt24nombreestadomapa),
ifnull(mt24idmunicipiomapa,'n'),
if(mt24clavemunicipiomapa='','n',mt24clavemunicipiomapa),
if(mt24nombremunicipiomapa='','n',mt24nombremunicipiomapa),
if(mt24claveniveladministrativoadicionalmapa='','n',mt24claveniveladministrativoadicionalmapa),
if(mt24nombreniveladministrativoadicionalmapa='','n',mt24nombreniveladministrativoadicionalmapa)));

update snib.regionhistorico
set llaveregionhistorico=MD5(CONCAT(if(claveestadohistorico='','n',claveestadohistorico),
if(nombreestadohistorico='','n',nombreestadohistorico),
if(clavemunicipiohistorico='','n',clavemunicipiohistorico),
if(nombremunicipiohistorico='','n',nombremunicipiohistorico)));

insert into snib.regionmapa(continentemapa,clavepaismapa,nombrepaismapa,idestadomapa,claveestadomapa,nombreestadomapa,idmunicipiomapa,clavemunicipiomapa,nombremunicipiomapa,claveniveladministrativoadicionalmapa,nombreniveladministrativoadicionalmapa,llaveregionmapa)
select j.continentemapa,j.clavepaismapa,j.nombrepaismapa,j.idestadomapa,j.claveestadomapa,j.nombreestadomapa,j.idmunicipiomapa,j.clavemunicipiomapa,j.nombremunicipiomapa,j.claveniveladministrativoadicionalmapa,j.nombreniveladministrativoadicionalmapa,j.llaveregionmapa
from snibdtap.po_ejemplarregionsitiosig j left join snib.regionmapa r using(llaveregionmapa)
where r.llaveregionmapa is null group by j.llaveregionmapa;

update snibdtap.po_ejemplarregionsitiosig j inner join snib.regionmapa r using(llaveregionmapa)
set j.idregionmapa=r.idregionmapa;


insert into snib.regionhistorico(llaveregionhistorico,claveestadohistorico,nombreestadohistorico,clavemunicipiohistorico,nombremunicipiohistorico);
select j.llaveregionhistorico,j.claveestadohistorico,j.nombreestadohistorico,j.clavemunicipiohistorico,j.nombremunicipiohistorico
from snibdtap.po_ejemplarregionsitiosig j left join snib.regionhistorico r using(llaveregionhistorico)
where r.llaveregionhistorico is null group by j.llaveregionhistorico;

update snibdtap.po_ejemplarregionsitiosig j inner join snib.regionhistorico r using(llaveregionhistorico)
set j.idregionhistorico=r.idregionhistorico;


insert into snib.mt24mapa(llavemt24mapa,mt24mapa,mt24idestadomapa,mt24claveestadomapa,mt24nombreestadomapa,mt24idmunicipiomapa,mt24clavemunicipiomapa,mt24nombremunicipiomapa,mt24claveniveladministrativoadicionalmapa,mt24nombreniveladministrativoadicionalmapa);
select j.llavemt24mapa,j.mt24mapa,j.mt24idestadomapa,j.mt24claveestadomapa,j.mt24nombreestadomapa,j.mt24idmunicipiomapa,j.mt24clavemunicipiomapa,j.mt24nombremunicipiomapa,j.mt24claveniveladministrativoadicionalmapa,j.mt24nombreniveladministrativoadicionalmapa
from snibdtap.po_ejemplarregionsitiosig j left join snib.mt24mapa r using(llavemt24mapa)
where r.llavemt24mapa is null group by j.llavemt24mapa;

update snibdtap.po_ejemplarregionsitiosig j inner join snib.mt24mapa r using(llavemt24mapa)
set j.idmt24mapa=r.idmt24mapa;