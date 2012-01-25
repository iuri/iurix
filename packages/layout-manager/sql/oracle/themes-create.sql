-- create layout manager themes datamodel
--
-- @author Don Baccus (dhogaza@pacifier.com)
-- @creation-date 2008-07-05
-- @version $Id: themes-create.sql,v 1.2 2008/08/03 18:05:33 donb Exp $

create table layout_themes (
    name                            varchar(100)
                                    constraint layout_themes_pk
                                    primary key,
    description                     varchar(250),
    template                        varchar(100)
);

comment on table layout_themes is '
    decoration templates for layout elements
';

comment on column layout_themes.template is '
    The path to the the theme template
';
