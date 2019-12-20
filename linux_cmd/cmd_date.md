* date用来显示具体的日期和24进制的时间
```
[jasmine.qian@ ~]$ date
Fri Jan 25 14:17:17 CST 2019
[jasmine.qian@ ~]$ date '+%Y-%m-%d %H:%M:%S'
2019-01-25 14:17:25
```

* 具体的显示昨天，或者一天之后，一天之前
```
[jasmine.qian@]$ date -d 'yesterday' '+%Y-%m-%d %H:%M:%S'
2019-01-24 14:18:53
[jasmine.qian@]$ date -d '1 days' '+%Y-%m-%d %H:%M:%S'
2019-01-26 14:19:04
[jasmine.qian@]$ date -d '+1 days' '+%Y-%m-%d %H:%M:%S'
2019-01-26 14:19:13
[jasmine.qian@]$ date -d '-1 days' '+%Y-%m-%d %H:%M:%S'
2019-01-24 14:19:21
[jasmine.qian@]$ date -d 'tomorrow' '+%Y-%m-%d %H:%M:%S'
2019-01-26 14:19:30
```

* 具体的显示一小时之后，一分钟之前等等
```
[jasmine.qian@]$ date -d '2 hours' '+%Y-%m-%d %H:%M:%S'
2019-01-25 16:21:33
[jasmine.qian@]$ date -d '-2 hours' '+%Y-%m-%d %H:%M:%S'
2019-01-25 12:21:39
[jasmine.qian@]$ date -d '-2 minutes' '+%Y-%m-%d %H:%M:%S'
2019-01-25 14:19:52
[jasmine.qian@]$ date -d '-2 minute' '+%Y-%m-%d %H:%M:%S'
2019-01-25 14:19:58
[jasmine.qian@]$ date -d '-2 hour 2 minute' '+%Y-%m-%d %H:%M:%S'
2019-01-25 12:24:08
```