#!/bin/sh

nginx -t
nginx -s reopen
nginx -s reload