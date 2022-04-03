import pandas as pd

n = pd.read_xml('../input/nvi-xml/napkozi.xml')
fn = napkozi.loc[:,['ido','maz','taz','sorsz','megj']].dropna()
fn.loc[:,['maz']] = fn.loc[:,['maz']].apply(lambda x: x.astype(int).astype(str).str.zfill(2))
fn.loc[:,['taz','sorsz']] = fn.loc[:,['taz','sorsz']].apply(lambda x: x.astype(int).astype(str).str.zfill(3))
fn['szk_id'] = 'ID2022'+fn.maz+fn.taz+fn.sorsz
fn = fn.loc[:,['ido','szk_id','megj']]
fn = fn.groupby(['szk_id', 'ido']).sum().groupby(level=0).cumsum().reset_index()
fn.to_csv('nvi.csv')
