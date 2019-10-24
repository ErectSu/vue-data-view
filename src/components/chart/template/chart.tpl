<template>
    <div class="chart">
        <vue-draggable-resizable :x="<%- config.config.dx%>"
                                 :y="<%- config.config.dy%>"
                                 :w="<%- config.config.width%>"
                                 :h="<%- config.config.height%>"
                                 @dragging="(left, top) =>onDrag('<%- config.chartId%>',left,top)"
                                 @resizing="(x, y, width, height) =>onResize('<%- config.chartId%>',x, y, width, height)"
                                 @activated="onActivated('<%- config.chartId%>')">
            <div @click="deleteChart('<%- config.chartId%>')" class="delete">删除</div>
            <div class="chart" ref="<%- config.chartId%>"
                               style="width: <%- config.config.width%>px;height:<%- config.config.height%>px;"
                               data-width="<%- config.config.width%>" data-height="<%- config.config.height%>" data-x="<%- config.config.dx%>" data-y="<%- config.config.dy%>"></div>
        </vue-draggable-resizable>
    </div>
</template>
<script>
    import './chart.styl'
    let echarts = require('echarts')
    import {getChartData} from "api/bar"
    import {getCommonConfig} from "common/js/normalize"
    import {socket} from "common/js/socket-client"
    import jsonobj from "common/js/chalk.project.json"
    import {mapMutations} from 'vuex'
    export default {
        mounted() {
            let mconfig = <%- JSON.stringify(config)%>
            let commonConfig = mconfig.config.commonConfig
            let userConfig = mconfig.config.userConfig
            let dataUrl = mconfig.config.dataUrl
            getChartData(dataUrl).then((res)=>{
               let tempConfig = getCommonConfig(res.data.array,commonConfig,userConfig,<%- config.chartType%>)
               echarts.registerTheme('chalk',jsonobj)
                this.$echarts = echarts.init(this.$refs.<%- config.chartId%>, 'chalk', {
                    width: mconfig.config.width,
                    height: mconfig.config.height
                })
                this.$echarts.setOption(tempConfig)
            })
        },
        methods:{
            onDrag(id,x,y){
                let position = {
                   dx:x,
                   dy:y,
                   chartId:id
                }
                socket.emit('onDragInPanel',JSON.stringify(position))
            },
            onResize(id,x,y,width,height){
               let position = {
                   dx:x,
                   dy:y,
                   width:width,
                   height:height,
                   chartId:id
               }
               socket.emit('onDragInPanel',JSON.stringify(position))
            },
            deleteChart(id){
                socket.emit('onDragRemove',id)
            },
            onActivated(id){
                let _set = this.$refs[id].dataset
                this.setChartId(id)
                this.setChartWidth(_set.width)
                this.setChartHeight(_set.height)
                this.setChartX(_set.x)
                this.setChartY(_set.y)
            },
            ...mapMutations({
                setChartId:'SET_CHART_ID',
                setChartWidth:'SET_CHART_WIDTH',
                setChartHeight:'SET_CHART_HEIGHT',
                setChartX:'SET_CHART_X',
                setChartY:'SET_CHART_Y'
            })
        }
    }
</script>